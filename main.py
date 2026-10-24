import sys
import os
import psycopg2
from datetime import date
from PyQt5.QtWidgets import (QApplication, QMainWindow, QWidget, QVBoxLayout, 
                             QHBoxLayout, QComboBox, QPushButton, QLabel, QMessageBox,
                             QScrollArea, QFrame, QGridLayout, QLineEdit, QTableWidget, 
                             QTableWidgetItem, QHeaderView, QDateEdit, QFormLayout)
from PyQt5.QtGui import QFont, QPixmap, QIcon, QIntValidator
from PyQt5.QtCore import Qt, QDate

DB_CONFIG = {
    "dbname": "chudo_obuv",
    "user": "postgres",
    "password": "qwerty",
    "host": "localhost",
    "port": "5432"
}

STYLESHEET = """
    QMainWindow, QWidget {
        background-color: #FFFFFF;
        font-family: Calibri;
        font-size: 14pt;
    }
    QComboBox, QLineEdit, QDateEdit {
        padding: 8px;
        border: 1px solid #D2F6E7;
        border-radius: 4px;
        background-color: #FFFFFF;
    }
    QPushButton {
        padding: 8px 16px;
        border: none;
        border-radius: 4px;
        background-color: #70B2AF;
        color: white;
        font-weight: bold;
    }
    QPushButton:hover {
        background-color: #5a918e;
    }
    QTableWidget {
        gridline-color: #D2F6E7;
    }
    QHeaderView::section {
        background-color: #70B2AF;
        color: white;
        font-weight: bold;
        padding: 5px;
    }
"""

def get_db_connection():
    try:
        return psycopg2.connect(**DB_CONFIG)
    except Exception as e:
        QMessageBox.critical(None, "Ошибка базы данных", f"Не удалось подключиться к БД:\n{e}")
        return None

def get_categories():
    conn = get_db_connection()
    if not conn: return []
    cursor = conn.cursor()
    cursor.execute("SELECT name FROM categories ORDER BY name")
    cats = [row[0] for row in cursor.fetchall()]
    cursor.close()
    conn.close()
    return cats

def get_catalog_data(category=None, search_text="", sort_by="price_asc"):
    conn = get_db_connection()
    if not conn: return []
    cursor = conn.cursor()
    
    query = """
        SELECT 
            p.id, c.name AS category, p.name AS product_name, p.manufacturer, 
            p.composition, p.description, p.image_path, p.base_price,
            CASE 
                WHEN NOT EXISTS (
                    SELECT 1 FROM order_items oi JOIN orders o ON oi.order_id = o.id
                    WHERE oi.product_id = p.id 
                      AND o.order_date >= date_trunc('month', CURRENT_DATE - INTERVAL '1 month')
                      AND o.order_date < date_trunc('month', CURRENT_DATE)
                ) THEN p.base_price * 0.75
                ELSE p.base_price 
            END AS final_price,
            COALESCE(SUM(s.quantity), 0) AS total_quantity
        FROM products p
        LEFT JOIN categories c ON p.category_id = c.id
        LEFT JOIN stock_items s ON p.id = s.product_id
    """
    
    conditions = []
    params = []
    
    if category and category != "Все категории":
        conditions.append("c.name = %s")
        params.append(category)
        
    if search_text:
        conditions.append("(p.name ILIKE %s OR p.description ILIKE %s)")
        params.extend([f"%{search_text}%", f"%{search_text}%"])
        
    if conditions:
        query += " WHERE " + " AND ".join(conditions)
        
    query += " GROUP BY p.id, c.name, p.name, p.manufacturer, p.composition, p.description, p.image_path, p.base_price"
    
    if sort_by == "price_asc":
        query += " ORDER BY final_price ASC"
    elif sort_by == "price_desc":
        query += " ORDER BY final_price DESC"
    else:
        query += " ORDER BY p.name ASC"
        
    cursor.execute(query, params)
    rows = cursor.fetchall()
    cursor.close()
    conn.close()
    return rows

def get_product_details(product_id):
    conn = get_db_connection()
    if not conn: return None, []
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT p.name, p.manufacturer, c.name, p.composition, p.description, p.image_path,
               CASE WHEN NOT EXISTS (
                   SELECT 1 FROM order_items oi JOIN orders o ON oi.order_id = o.id
                   WHERE oi.product_id = p.id AND o.order_date >= date_trunc('month', CURRENT_DATE - INTERVAL '1 month')
                   AND o.order_date < date_trunc('month', CURRENT_DATE)
               ) THEN p.base_price * 0.75 ELSE p.base_price END AS final_price
        FROM products p LEFT JOIN categories c ON p.category_id = c.id WHERE p.id = %s
    """, (product_id,))
    product = cursor.fetchone()
    
    cursor.execute("""
        SELECT sz.size_value, s.quantity 
        FROM stock_items s JOIN sizes sz ON s.size_id = sz.id 
        WHERE s.product_id = %s AND s.quantity > 0 ORDER BY sz.size_value
    """, (product_id,))
    sizes = cursor.fetchall()
    
    cursor.close()
    conn.close()
    return product, sizes

def create_order(user_id, items):
    conn = get_db_connection()
    if not conn: return False
    cursor = conn.cursor()
    try:
        cursor.execute("INSERT INTO orders (user_id, order_date) VALUES (%s, CURRENT_DATE) RETURNING id", (user_id,))
        order_id = cursor.fetchone()[0]
        
        for item in items:
            cursor.execute("""
                INSERT INTO order_items (order_id, product_id, size_id, quantity, price_per_unit)
                VALUES (%s, %s, %s, %s, %s)
            """, (order_id, item['product_id'], item['size_id'], item['quantity'], item['price']))
            
            cursor.execute("""
                UPDATE stock_items SET quantity = quantity - %s 
                WHERE product_id = %s AND size_id = %s
            """, (item['quantity'], item['product_id'], item['size_id']))
            
        conn.commit()
        cursor.close()
        conn.close()
        return True
    except Exception as e:
        conn.rollback()
        cursor.close()
        conn.close()
        QMessageBox.critical(None, "Ошибка", f"Не удалось оформить заказ:\n{e}")
        return False

def get_orders_list(role, user_id=None):
    conn = get_db_connection()
    if not conn: return []
    cursor = conn.cursor()
    
    if role in ['admin', 'manager']:
        cursor.execute("""
            SELECT o.id, o.order_date, u.last_name, u.first_name, u.middle_name
            FROM orders o LEFT JOIN users u ON o.user_id = u.id
            ORDER BY o.order_date DESC
        """)
    else:
        cursor.execute("""
            SELECT o.id, o.order_date, u.last_name, u.first_name, u.middle_name
            FROM orders o JOIN users u ON o.user_id = u.id
            WHERE o.user_id = %s ORDER BY o.order_date DESC
        """, (user_id,))
        
    rows = cursor.fetchall()
    cursor.close()
    conn.close()
    return rows

def get_order_details(order_id):
    conn = get_db_connection()
    if not conn: return None, []
    cursor = conn.cursor()
    
    cursor.execute("SELECT order_date, user_id FROM orders WHERE id = %s", (order_id,))
    order_info = cursor.fetchone()
    
    cursor.execute("""
        SELECT oi.id, p.name, p.manufacturer, sz.size_value, oi.quantity, oi.price_per_unit, 
               (oi.quantity * oi.price_per_unit) as total
        FROM order_items oi
        JOIN products p ON oi.product_id = p.id
        JOIN sizes sz ON oi.size_id = sz.id
        WHERE oi.order_id = %s
    """, (order_id,))
    items = cursor.fetchall()
    
    cursor.close()
    conn.close()
    return order_info, items

def update_order_date(order_id, new_date):
    conn = get_db_connection()
    if not conn: return False
    cursor = conn.cursor()
    try:
        cursor.execute("UPDATE orders SET order_date = %s WHERE id = %s", (new_date, order_id))
        conn.commit()
        cursor.close()
        conn.close()
        return True
    except Exception as e:
        conn.rollback()
        cursor.close()
        conn.close()
        return False

def delete_order_item(item_id, product_id, size_id, quantity):
    conn = get_db_connection()
    if not conn: return False
    cursor = conn.cursor()
    try:
        cursor.execute("DELETE FROM order_items WHERE id = %s", (item_id,))
        cursor.execute("""
            UPDATE stock_items SET quantity = quantity + %s 
            WHERE product_id = %s AND size_id = %s
        """, (quantity, product_id, size_id))
        conn.commit()
        cursor.close()
        conn.close()
        return True
    except Exception as e:
        conn.rollback()
        cursor.close()
        conn.close()
        return False


class LoginWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Чудо Обувь - Авторизация")
        self.resize(400, 200)
        self.user_id = None
        self.init_ui()
        self.load_logins()

    def init_ui(self):
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        layout = QVBoxLayout(central_widget)
        layout.setContentsMargins(50, 50, 50, 50)

        self.login_combo = QComboBox()
        self.login_combo.setPlaceholderText("Выберите логин")
        layout.addWidget(self.login_combo)

        self.login_btn = QPushButton("Войти")
        self.login_btn.clicked.connect(self.on_login)
        layout.addWidget(self.login_btn)

    def load_logins(self):
        conn = get_db_connection()
        if not conn: return
        cursor = conn.cursor()
        cursor.execute("SELECT id, login FROM users ORDER BY login")
        self.users = {row[1]: row[0] for row in cursor.fetchall()}
        self.login_combo.addItems(list(self.users.keys()))
        cursor.close()
        conn.close()

    def on_login(self):
        login = self.login_combo.currentText()
        if not login:
            QMessageBox.warning(self, "Ошибка ввода", "Пожалуйста, выберите логин из списка.")
            return

        conn = get_db_connection()
        if not conn: return
        cursor = conn.cursor()
        cursor.execute("SELECT last_name, first_name, middle_name, role FROM users WHERE login = %s", (login,))
        user_data = cursor.fetchone()
        cursor.close()
        conn.close()

        if user_data:
            self.user_id = self.users[login]
            last_name, first_name, middle_name, role = user_data
            full_name = f"{last_name} {first_name} {middle_name}"
            self.open_main_window(full_name, role)
        else:
            QMessageBox.warning(self, "Ошибка авторизации", "Пользователь не найден в системе.")

    def open_main_window(self, full_name, role):
        self.main_window = MainWindow(full_name, role, self.user_id)
        self.main_window.show()
        self.close()


class MainWindow(QMainWindow):
    def __init__(self, full_name, role, user_id):
        super().__init__()
        self.setWindowTitle(f"Чудо Обувь - Каталог ({role})")
        self.setWindowIcon(QIcon("Чудо Обувь.ico"))
        self.resize(1200, 700)
        self.full_name = full_name
        self.role = role
        self.user_id = user_id
        self.init_ui()
        self.load_catalog()

    def init_ui(self):
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        main_layout = QVBoxLayout(central_widget)

        header_layout = QHBoxLayout()
        logo_label = QLabel()
        if os.path.exists("Чудо Обувь.png"):
            pixmap = QPixmap("Чудо Обувь.png").scaled(150, 80, Qt.KeepAspectRatio)
            logo_label.setPixmap(pixmap)
        header_layout.addWidget(logo_label)
        header_layout.addStretch()
        
        self.fio_label = QLabel(self.full_name)
        self.fio_label.setStyleSheet("font-weight: bold; color: #70B2AF; font-size: 16pt;")
        header_layout.addWidget(self.fio_label)
        main_layout.addLayout(header_layout)

        if self.role in ['admin', 'manager']:
            self.orders_btn = QPushButton("Управление заказами")
            self.orders_btn.clicked.connect(self.open_orders)
            main_layout.addWidget(self.orders_btn)

        filter_layout = QHBoxLayout()
        
        self.search_input = QLineEdit()
        self.search_input.setPlaceholderText("Поиск по наименованию или описанию...")
        self.search_input.textChanged.connect(self.load_catalog)
        filter_layout.addWidget(self.search_input)

        self.category_combo = QComboBox()
        self.category_combo.addItem("Все категории")
        self.category_combo.addItems(get_categories())
        self.category_combo.currentTextChanged.connect(self.load_catalog)
        filter_layout.addWidget(self.category_combo)

        self.sort_combo = QComboBox()
        self.sort_combo.addItems(["Цена: по возрастанию", "Цена: по убыванию", "По наименованию"])
        self.sort_combo.currentTextChanged.connect(self.load_catalog)
        filter_layout.addWidget(self.sort_combo)

        main_layout.addLayout(filter_layout)

        self.catalog_widget = QWidget()
        self.catalog_layout = QGridLayout(self.catalog_widget)
        self.catalog_layout.setSpacing(15)

        scroll = QScrollArea()
        scroll.setWidgetResizable(True)
        scroll.setWidget(self.catalog_widget)
        main_layout.addWidget(scroll)

    def load_catalog(self):
        self.clear_catalog()
        
        category = self.category_combo.currentText()
        search_text = self.search_input.text()
        sort_map = {"Цена: по возрастанию": "price_asc", "Цена: по убыванию": "price_desc", "По наименованию": "name"}
        sort_by = sort_map.get(self.sort_combo.currentText(), "price_asc")
        
        data = get_catalog_data(category, search_text, sort_by)
        
        for row_idx, row in enumerate(data):
            prod_id, cat_name, name, manufacturer, composition, description, image_path, base_price, final_price, total_quantity = row
            
            card = QFrame()
            card.setFrameStyle(QFrame.Box)
            bg_color = "#FF8080" if total_quantity <= 3 else "#D2F6E7"
            card.setStyleSheet(f"QFrame {{ background-color: {bg_color}; border: 1px solid #70B2AF; border-radius: 5px; padding: 10px; }}")
            
            card_layout = QVBoxLayout(card)
            
            image_label = QLabel()
            image_path_full = os.path.join("Images", image_path) if image_path else None
            if image_path_full and os.path.exists(image_path_full):
                pixmap = QPixmap(image_path_full).scaled(200, 150, Qt.KeepAspectRatio)
            else:
                pixmap = QPixmap("picture.png").scaled(200, 150, Qt.KeepAspectRatio)
            image_label.setPixmap(pixmap)
            image_label.setAlignment(Qt.AlignCenter)
            card_layout.addWidget(image_label)
            
            card_layout.addWidget(QLabel(f"<b>{name}</b>"))
            card_layout.addWidget(QLabel(f"Категория: {cat_name or '-'}"))
            card_layout.addWidget(QLabel(f"Производство: {manufacturer}"))
            card_layout.addWidget(QLabel(f"Цена: {final_price:.2f} руб."))
            card_layout.addWidget(QLabel(f"Остаток: {'мало' if total_quantity <= 5 else 'много'} ({total_quantity} пар)"))
            
            btn = QPushButton("Подробнее")
            btn.clicked.connect(lambda checked, pid=prod_id: self.open_product_detail(pid))
            card_layout.addWidget(btn)
            
            col = row_idx % 3
            row_pos = row_idx // 3
            self.catalog_layout.addWidget(card, row_pos, col)

    def clear_catalog(self):
        while self.catalog_layout.count():
            item = self.catalog_layout.takeAt(0)
            if item.widget():
                item.widget().deleteLater()

    def open_product_detail(self, product_id):
        self.detail_window = ProductDetailWindow(product_id, self.role, self.user_id, self.full_name)
        self.detail_window.show()
        self.close()

    def open_orders(self):
        self.orders_window = OrdersWindow(self.role, self.user_id, self.full_name)
        self.orders_window.show()
        self.close()


class ProductDetailWindow(QMainWindow):
    def __init__(self, product_id, role, user_id, full_name):
        super().__init__()
        self.setWindowTitle("Чудо Обувь - Просмотр товара")
        self.resize(600, 500)
        self.product_id = product_id
        self.role = role
        self.user_id = user_id
        self.full_name = full_name
        self.init_ui()

    def init_ui(self):
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        layout = QVBoxLayout(central_widget)

        back_btn = QPushButton("Назад в каталог")
        back_btn.clicked.connect(self.go_back)
        layout.addWidget(back_btn)

        product, sizes = get_product_details(self.product_id)
        if not product:
            QMessageBox.critical(self, "Ошибка", "Товар не найден.")
            return

        name, manufacturer, category, composition, description, image_path, final_price = product

        form_layout = QFormLayout()
        form_layout.addRow("Наименование:", QLabel(name))
        form_layout.addRow("Производство:", QLabel(manufacturer))
        form_layout.addRow("Категория:", QLabel(category or "-"))
        form_layout.addRow("Цена со скидкой:", QLabel(f"{final_price:.2f} руб."))
        form_layout.addRow("Состав:", QLabel(composition or "-"))
        form_layout.addRow("Описание:", QLabel(description or "-"))

        image_label = QLabel()
        image_path_full = os.path.join("Images", image_path) if image_path else None
        if image_path_full and os.path.exists(image_path_full):
            pixmap = QPixmap(image_path_full).scaled(300, 200, Qt.KeepAspectRatio)
        else:
            pixmap = QPixmap("picture.png").scaled(300, 200, Qt.KeepAspectRatio)
        image_label.setPixmap(pixmap)
        image_label.setAlignment(Qt.AlignCenter)
        
        layout.addWidget(image_label)
        layout.addLayout(form_layout)

        if sizes:
            size_layout = QHBoxLayout()
            self.size_combo = QComboBox()
            self.size_combo.addItems([f"{s[0]} (остаток: {s[1]})" for s in sizes])
            self.size_combo.setItemData(0, [s[0] for s in sizes][0]) 
            self.size_combo.setItemData(0, [s[1] for s in sizes][0], Qt.UserRole)
            size_layout.addWidget(QLabel("Выберите размер:"))
            size_layout.addWidget(self.size_combo)
            layout.addLayout(size_layout)

            qty_layout = QHBoxLayout()
            self.qty_input = QLineEdit()
            self.qty_input.setValidator(QIntValidator(1, 99))
            self.qty_input.setText("1")
            qty_layout.addWidget(QLabel("Количество:"))
            qty_layout.addWidget(self.qty_input)
            layout.addLayout(qty_layout)

            order_btn = QPushButton("Оформить заказ")
            order_btn.clicked.connect(self.place_order)
            layout.addWidget(order_btn)
        else:
            layout.addWidget(QLabel("Товар временно отсутствует на складе."))

    def place_order(self):
        size_data = self.size_combo.currentData(Qt.UserRole)
        if not size_data:
            QMessageBox.warning(self, "Ошибка", "Необходимо выбрать размер.")
            return

        size_value = self.size_combo.currentText().split(" ")[0]
        quantity = int(self.qty_input.text())

        if quantity > size_data:
            QMessageBox.warning(self, "Ошибка", f"Выбранное количество ({quantity}) превышает доступный остаток ({size_data}).")
            return

        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT id FROM sizes WHERE size_value = %s", (size_value,))
        size_id = cursor.fetchone()[0]
        cursor.close()
        conn.close()

        items = [{
            'product_id': self.product_id,
            'size_id': size_id,
            'quantity': quantity,
            'price': float(self.findChild(QLabel, "").text().split()[0]) 
        }]
        
        if create_order(self.user_id, items):
            QMessageBox.information(self, "Успех", "Заказ успешно оформлен!")
            self.go_back()

    def go_back(self):
        self.main_window = MainWindow(self.full_name, self.role, self.user_id)
        self.main_window.show()
        self.close()


class OrdersWindow(QMainWindow):
    def __init__(self, role, user_id, full_name):
        super().__init__()
        self.setWindowTitle("Чудо Обувь - Управление заказами")
        self.resize(1000, 600)
        self.role = role
        self.user_id = user_id
        self.full_name = full_name
        self.init_ui()
        self.load_orders()

    def init_ui(self):
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        layout = QVBoxLayout(central_widget)

        back_btn = QPushButton("Назад в каталог")
        back_btn.clicked.connect(self.go_back)
        layout.addWidget(back_btn)

        self.table = QTableWidget()
        self.table.setColumnCount(4)
        self.table.setHorizontalHeaderLabels(["ID заказа", "Дата заказа", "ФИО клиента", "Действия"])
        self.table.horizontalHeader().setSectionResizeMode(QHeaderView.Stretch)
        layout.addWidget(self.table)

    def load_orders(self):
        orders = get_orders_list(self.role, self.user_id)
        self.table.setRowCount(len(orders))
        
        for row_idx, order in enumerate(orders):
            order_id, order_date, last_name, first_name, middle_name = order
            fio = f"{last_name or ''} {first_name or ''} {middle_name or ''}".strip()
            
            self.table.setItem(row_idx, 0, QTableWidgetItem(str(order_id)))
            self.table.setItem(row_idx, 1, QTableWidgetItem(str(order_date)))
            self.table.setItem(row_idx, 2, QTableWidgetItem(fio))
            
            btn = QPushButton("Просмотр / Редактирование")
            btn.clicked.connect(lambda checked, oid=order_id: self.open_order_detail(oid))
            self.table.setCellWidget(row_idx, 3, btn)

    def open_order_detail(self, order_id):
        self.detail_window = OrderDetailWindow(order_id, self.role, self.full_name, self.user_id)
        self.detail_window.show()
        self.close()

    def go_back(self):
        self.main_window = MainWindow(self.full_name, self.role, self.user_id)
        self.main_window.show()
        self.close()


class OrderDetailWindow(QMainWindow):
    def __init__(self, order_id, role, full_name, user_id):
        super().__init__()
        self.setWindowTitle(f"Чудо Обувь - Заказ №{order_id}")
        self.resize(800, 500)
        self.order_id = order_id
        self.role = role
        self.full_name = full_name
        self.user_id = user_id
        self.init_ui()

    def init_ui(self):
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        layout = QVBoxLayout(central_widget)

        back_btn = QPushButton("Назад к списку заказов")
        back_btn.clicked.connect(self.go_back)
        layout.addWidget(back_btn)

        order_info, items = get_order_details(self.order_id)
        if not order_info:
            QMessageBox.critical(self, "Ошибка", "Заказ не найден.")
            return

        order_date, user_id = order_info

        info_layout = QHBoxLayout()
        info_layout.addWidget(QLabel(f"Дата заказа:"))
        self.date_edit = QDateEdit()
        self.date_edit.setDate(QDate.fromString(str(order_date), "yyyy-MM-dd"))
        self.date_edit.setCalendarPopup(True)
        info_layout.addWidget(self.date_edit)
        
        if self.role == 'admin':
            save_date_btn = QPushButton("Сохранить дату")
            save_date_btn.clicked.connect(self.save_date)
            info_layout.addWidget(save_date_btn)
            
        info_layout.addStretch()
        layout.addLayout(info_layout)

        self.table = QTableWidget()
        self.table.setColumnCount(8)
        self.table.setHorizontalHeaderLabels(["ID позиции", "Модель", "Производство", "Размер", "Кол-во", "Цена за ед.", "Сумма", "Действия"])
        self.table.horizontalHeader().setSectionResizeMode(QHeaderView.Stretch)
        layout.addWidget(self.table)

        total_sum = 0
        self.table.setRowCount(len(items))
        for row_idx, item in enumerate(items):
            item_id, name, manufacturer, size_value, quantity, price, total = item
            total_sum += total
            
            self.table.setItem(row_idx, 0, QTableWidgetItem(str(item_id)))
            self.table.setItem(row_idx, 1, QTableWidgetItem(name))
            self.table.setItem(row_idx, 2, QTableWidgetItem(manufacturer))
            self.table.setItem(row_idx, 3, QTableWidgetItem(size_value))
            self.table.setItem(row_idx, 4, QTableWidgetItem(str(quantity)))
            self.table.setItem(row_idx, 5, QTableWidgetItem(f"{price:.2f}"))
            self.table.setItem(row_idx, 6, QTableWidgetItem(f"{total:.2f}"))
            
            if self.role == 'admin':
                del_btn = QPushButton("Удалить позицию")
                del_btn.setStyleSheet("background-color: #FF8080;")
                del_btn.clicked.connect(lambda checked, iid=item_id, pid=self.get_product_id(name, manufacturer), sid=self.get_size_id(size_value), q=quantity: self.delete_item(iid, pid, sid, q))
                self.table.setCellWidget(row_idx, 7, del_btn)

        layout.addWidget(QLabel(f"<b>Итоговая сумма по заказу: {total_sum:.2f} руб.</b>"))

    def get_product_id(self, name, manufacturer):
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT id FROM products WHERE name = %s AND manufacturer = %s", (name, manufacturer))
        res = cursor.fetchone()
        cursor.close()
        conn.close()
        return res[0] if res else None

    def get_size_id(self, size_value):
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT id FROM sizes WHERE size_value = %s", (size_value,))
        res = cursor.fetchone()
        cursor.close()
        conn.close()
        return res[0] if res else None

    def save_date(self):
        new_date = self.date_edit.date().toString("yyyy-MM-dd")
        if update_order_date(self.order_id, new_date):
            QMessageBox.information(self, "Успех", "Дата заказа успешно обновлена.")
        else:
            QMessageBox.critical(self, "Ошибка", "Не удалось обновить дату заказа.")

    def delete_item(self, item_id, product_id, size_id, quantity):
        reply = QMessageBox.question(self, "Подтверждение", "Вы уверены, что хотите удалить эту позицию? Остаток будет возвращен на склад.", QMessageBox.Yes | QMessageBox.No)
        if reply == QMessageBox.Yes:
            if delete_order_item(item_id, product_id, size_id, quantity):
                QMessageBox.information(self, "Успех", "Позиция удалена, остаток обновлен.")
                self.init_ui()
            else:
                QMessageBox.critical(self, "Ошибка", "Не удалось удалить позицию.")

    def go_back(self):
        self.orders_window = OrdersWindow(self.role, self.user_id, self.full_name)
        self.orders_window.show()
        self.close()


if __name__ == "__main__":
    app = QApplication(sys.argv)
    app.setStyleSheet(STYLESHEET)
    app.setFont(QFont("Calibri", 14))
    
    window = LoginWindow()
    window.show()
    
    sys.exit(app.exec_())