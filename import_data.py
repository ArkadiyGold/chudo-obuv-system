import pandas as pd
import psycopg2

DB_CONFIG = {
    "dbname": "chudo_obuv",
    "user": "postgres",
    "password": "qwerty",
    "host": "localhost",
    "port": "5432"
}

def import_users():
    df = pd.read_excel('Users_import.xlsx')
    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()
    cursor.execute("TRUNCATE TABLE users RESTART IDENTITY CASCADE;")
    
    for _, row in df.iterrows():
        cursor.execute("""
            INSERT INTO users (login, role, last_name, first_name, middle_name)
            VALUES (%s, %s, %s, %s, %s)
            ON CONFLICT (login) DO NOTHING;
        """, (
            str(row['Логин']),
            str(row['Роль']),
            str(row['Фамилия']),
            str(row['Имя']),
            str(row['Отчество'])
        ))
    
    conn.commit()
    cursor.close()
    conn.close()

def import_categories():
    df = pd.read_excel('Orders_import.xlsx')
    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()
    cursor.execute("TRUNCATE TABLE categories RESTART IDENTITY CASCADE;")
    
    categories = df['Категория'].dropna().unique()
    for cat in categories:
        cursor.execute("""
            INSERT INTO categories (name) VALUES (%s)
            ON CONFLICT DO NOTHING;
        """, (str(cat),))
    
    conn.commit()
    cursor.close()
    conn.close()

def import_products():
    df = pd.read_excel('Products_import.xlsx')
    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()
    cursor.execute("TRUNCATE TABLE products RESTART IDENTITY CASCADE;")
    
    for _, row in df.iterrows():
        image_path = str(row['Изображение']) if pd.notna(row['Изображение']) else None
        
        cursor.execute("""
            INSERT INTO products (name, manufacturer, composition, description, base_price, image_path)
            VALUES (%s, %s, %s, %s, %s, %s)
            ON CONFLICT DO NOTHING;
        """, (
            str(row['Наименование товара']),
            str(row['Производство']),
            str(row['Состав']),
            str(row['Описание']),
            float(row['Цена']),
            image_path
        ))
    
    conn.commit()
    cursor.close()
    conn.close()

def import_sizes():
    df = pd.read_excel('Sizes_import.xlsx')
    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()
    cursor.execute("TRUNCATE TABLE sizes RESTART IDENTITY CASCADE;")
    
    for _, row in df.iterrows():
        raw_size = row['Размер']
        if isinstance(raw_size, float) and raw_size == int(raw_size):
            size_str = str(int(raw_size))
        else:
            size_str = str(raw_size).strip()
        
        cursor.execute("""
            INSERT INTO sizes (size_value) VALUES (%s)
            ON CONFLICT DO NOTHING;
        """, (size_str,))
    
    conn.commit()
    cursor.close()
    conn.close()
    print("Размеры импортированы")

def import_stock_items():
    df = pd.read_excel('Stock_Items_import.xlsx')
    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()
    cursor.execute("TRUNCATE TABLE stock_items RESTART IDENTITY CASCADE;")
    
    for _, row in df.iterrows():
        cursor.execute("""
            SELECT id FROM products 
            WHERE name = %s AND manufacturer = %s
        """, (str(row['Наименование товара']), str(row['Производство'])))
        product_result = cursor.fetchone()
        if not product_result:
            continue
        product_id = product_result[0]
        
        cursor.execute("""
            SELECT id FROM sizes WHERE size_value = %s
        """, (str(row['Размер']),))
        size_result = cursor.fetchone()
        if not size_result:
            continue
        size_id = size_result[0]
        
        cursor.execute("""
            INSERT INTO stock_items (product_id, size_id, quantity)
            VALUES (%s, %s, %s)
            ON CONFLICT (product_id, size_id) DO UPDATE SET quantity = EXCLUDED.quantity;
        """, (product_id, size_id, int(row['Количество доступное для заказа'])))
    
    conn.commit()
    cursor.close()
    conn.close()

def import_orders():
    df = pd.read_excel('Orders_import.xlsx')
    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()
    cursor.execute("TRUNCATE TABLE order_items RESTART IDENTITY CASCADE;")
    cursor.execute("TRUNCATE TABLE orders RESTART IDENTITY CASCADE;")
    
    orders_created = {}
    skipped_products = 0
    skipped_sizes = 0
    
    for idx, row in df.iterrows():
        order_number = int(row['Номер заказа'])
        
        if order_number not in orders_created:
            fio = str(row['ФИО']).split()
            last_name = fio[0] if len(fio) > 0 else ''
            first_name = fio[1] if len(fio) > 1 else ''
            middle_name = fio[2] if len(fio) > 2 else ''
            
            cursor.execute("""
                SELECT id FROM users 
                WHERE last_name = %s AND first_name = %s AND middle_name = %s
            """, (last_name, first_name, middle_name))
            user_result = cursor.fetchone()
            user_id = user_result[0] if user_result else 1
            
            order_date = row['Дата заказа']
            if hasattr(order_date, 'strftime'):
                order_date = order_date.strftime('%Y-%m-%d')
            
            cursor.execute("""
                INSERT INTO orders (user_id, order_date)
                VALUES (%s, %s)
                RETURNING id;
            """, (user_id, order_date))
            order_id = cursor.fetchone()[0]
            orders_created[order_number] = order_id
        else:
            order_id = orders_created[order_number]
        
        product_name = str(row['Наименование товара']).strip()
        manufacturer = str(row['Производство']).strip()

        raw_size = row['Размер']
        if isinstance(raw_size, float) and raw_size == int(raw_size):
            size_value = str(int(raw_size))
        else:
            size_value = str(raw_size).strip()

        cursor.execute("""
            SELECT id, name FROM products 
            WHERE TRIM(manufacturer) = %s
              AND TRIM(name) ILIKE %s
            LIMIT 1
        """, (manufacturer, f"%{product_name[:30]}%"))
        product_result = cursor.fetchone()
        
        if not product_result:
            cursor.execute("""
                SELECT id, name FROM products 
                WHERE TRIM(manufacturer) = %s
                  AND TRIM(name) ILIKE %s
                LIMIT 1
            """, (manufacturer, f"%{product_name}%"))
            product_result = cursor.fetchone()
        
        if not product_result:
            print(f"Строка {idx}: Товар не найден: '{product_name}' / '{manufacturer}'")
            skipped_products += 1
            continue
        product_id = product_result[0]
        
        cursor.execute("""
            SELECT id FROM sizes WHERE TRIM(size_value) = %s
        """, (size_value,))
        size_result = cursor.fetchone()
        
        if not size_result:
            print(f"Строка {idx}: Размер не найден: '{size_value}' для товара '{product_name}'")
            skipped_sizes += 1
            continue
        size_id = size_result[0]
        
        cursor.execute("""
            INSERT INTO order_items (order_id, product_id, size_id, quantity, price_per_unit)
            VALUES (%s, %s, %s, %s, %s);
        """, (
            order_id,
            product_id,
            size_id,
            int(row['Количество']),
            float(row['Цена за единицу'])
        ))
    
    conn.commit()
    cursor.close()
    conn.close()
    print(f"Импорт заказов завершён")

def update_categories():
    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    cursor.execute("""
        UPDATE products SET category_id = 
            CASE 
                WHEN name ILIKE '%детск%' THEN 1
                WHEN name ILIKE '%женск%' OR name ILIKE '%Женские%' THEN 2
                WHEN name ILIKE '%мужск%' OR name ILIKE '%Мужские%' THEN 3
                WHEN name ILIKE '%Сапоги%' AND name NOT ILIKE '%детск%' THEN 2
                WHEN name ILIKE '%Босоножки%' AND name NOT ILIKE '%детск%' THEN 2
                WHEN name ILIKE '%Туфли%' AND name NOT ILIKE '%детск%' AND name NOT ILIKE '%мужск%' THEN 2
                WHEN name ILIKE '%Ботинки%' THEN 3
                WHEN name ILIKE '%Кроссовки%' AND name NOT ILIKE '%детск%' THEN 3
                ELSE NULL
            END
        WHERE category_id IS NULL;
    """)
    
    conn.commit()
    cursor.close()
    conn.close()
    print("Категории обновлены")

if __name__ == "__main__":
    import_users()
    import_categories()
    import_products()
    import_sizes()
    import_stock_items()
    import_orders()
    update_categories()
    print("Импорт завершён")