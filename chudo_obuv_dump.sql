--
-- PostgreSQL database dump
--

\restrict ZgeZx0D9zbbfFM6mwr2fSlxHhgjzGVkOMifMXKeZLcKNNJ2OPyaGdgmx8HZbnWp

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

-- Started on 2026-10-24 19:14:56

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE chudo_obuv;
--
-- TOC entry 4985 (class 1262 OID 33261)
-- Name: chudo_obuv; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE chudo_obuv WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_United States.1252';


ALTER DATABASE chudo_obuv OWNER TO postgres;

\unrestrict ZgeZx0D9zbbfFM6mwr2fSlxHhgjzGVkOMifMXKeZLcKNNJ2OPyaGdgmx8HZbnWp
\connect chudo_obuv
\restrict ZgeZx0D9zbbfFM6mwr2fSlxHhgjzGVkOMifMXKeZLcKNNJ2OPyaGdgmx8HZbnWp

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 222 (class 1259 OID 33275)
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categories (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.categories OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 33274)
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categories_id_seq OWNER TO postgres;

--
-- TOC entry 4986 (class 0 OID 0)
-- Dependencies: 221
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- TOC entry 232 (class 1259 OID 33347)
-- Name: order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_items (
    id integer NOT NULL,
    order_id integer,
    product_id integer,
    size_id integer,
    quantity integer NOT NULL,
    price_per_unit numeric(10,2) NOT NULL
);


ALTER TABLE public.order_items OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 33346)
-- Name: order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_items_id_seq OWNER TO postgres;

--
-- TOC entry 4987 (class 0 OID 0)
-- Dependencies: 231
-- Name: order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_items_id_seq OWNED BY public.order_items.id;


--
-- TOC entry 230 (class 1259 OID 33332)
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    id integer NOT NULL,
    user_id integer,
    order_date date DEFAULT CURRENT_DATE NOT NULL
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 33331)
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_id_seq OWNER TO postgres;

--
-- TOC entry 4988 (class 0 OID 0)
-- Dependencies: 229
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- TOC entry 224 (class 1259 OID 33284)
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id integer NOT NULL,
    category_id integer,
    name character varying(255) NOT NULL,
    manufacturer character varying(100),
    composition text,
    description text,
    base_price numeric(10,2) NOT NULL,
    image_path character varying(255)
);


ALTER TABLE public.products OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 33283)
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.products_id_seq OWNER TO postgres;

--
-- TOC entry 4989 (class 0 OID 0)
-- Dependencies: 223
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- TOC entry 226 (class 1259 OID 33301)
-- Name: sizes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sizes (
    id integer NOT NULL,
    size_value character varying(10) NOT NULL
);


ALTER TABLE public.sizes OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 33300)
-- Name: sizes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sizes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sizes_id_seq OWNER TO postgres;

--
-- TOC entry 4990 (class 0 OID 0)
-- Dependencies: 225
-- Name: sizes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sizes_id_seq OWNED BY public.sizes.id;


--
-- TOC entry 228 (class 1259 OID 33310)
-- Name: stock_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stock_items (
    id integer NOT NULL,
    product_id integer,
    size_id integer,
    quantity integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.stock_items OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 33309)
-- Name: stock_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.stock_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.stock_items_id_seq OWNER TO postgres;

--
-- TOC entry 4991 (class 0 OID 0)
-- Dependencies: 227
-- Name: stock_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.stock_items_id_seq OWNED BY public.stock_items.id;


--
-- TOC entry 220 (class 1259 OID 33263)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    login character varying(50) NOT NULL,
    role character varying(50) NOT NULL,
    last_name character varying(50),
    first_name character varying(50),
    middle_name character varying(50)
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 33262)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- TOC entry 4992 (class 0 OID 0)
-- Dependencies: 219
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 4786 (class 2604 OID 33278)
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- TOC entry 4793 (class 2604 OID 33350)
-- Name: order_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items ALTER COLUMN id SET DEFAULT nextval('public.order_items_id_seq'::regclass);


--
-- TOC entry 4791 (class 2604 OID 33335)
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- TOC entry 4787 (class 2604 OID 33287)
-- Name: products id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- TOC entry 4788 (class 2604 OID 33304)
-- Name: sizes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sizes ALTER COLUMN id SET DEFAULT nextval('public.sizes_id_seq'::regclass);


--
-- TOC entry 4789 (class 2604 OID 33313)
-- Name: stock_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_items ALTER COLUMN id SET DEFAULT nextval('public.stock_items_id_seq'::regclass);


--
-- TOC entry 4785 (class 2604 OID 33266)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 4969 (class 0 OID 33275)
-- Dependencies: 222
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.categories VALUES (1, 'Детская обувь');
INSERT INTO public.categories VALUES (2, 'Женская обувь');
INSERT INTO public.categories VALUES (3, 'Мужская обувь');


--
-- TOC entry 4979 (class 0 OID 33347)
-- Dependencies: 232
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.order_items VALUES (1, 1, 1, 3, 1, 2190.00);
INSERT INTO public.order_items VALUES (2, 1, 7, 5, 1, 2790.00);
INSERT INTO public.order_items VALUES (3, 2, 10, 19, 1, 25000.00);
INSERT INTO public.order_items VALUES (4, 2, 13, 23, 1, 7500.00);
INSERT INTO public.order_items VALUES (5, 3, 12, 21, 1, 17000.00);
INSERT INTO public.order_items VALUES (6, 3, 20, 21, 1, 8565.00);
INSERT INTO public.order_items VALUES (7, 3, 22, 18, 1, 7795.00);
INSERT INTO public.order_items VALUES (8, 4, 17, 23, 1, 7757.00);
INSERT INTO public.order_items VALUES (9, 4, 16, 23, 1, 12340.00);
INSERT INTO public.order_items VALUES (10, 4, 15, 25, 1, 7130.00);
INSERT INTO public.order_items VALUES (11, 4, 21, 19, 1, 8765.00);
INSERT INTO public.order_items VALUES (12, 4, 11, 25, 1, 15000.00);
INSERT INTO public.order_items VALUES (13, 5, 2, 29, 1, 9567.00);
INSERT INTO public.order_items VALUES (14, 5, 29, 29, 1, 21500.00);
INSERT INTO public.order_items VALUES (15, 5, 24, 25, 1, 7890.00);
INSERT INTO public.order_items VALUES (16, 6, 26, 27, 1, 24569.00);
INSERT INTO public.order_items VALUES (17, 6, 30, 31, 1, 14567.00);
INSERT INTO public.order_items VALUES (18, 6, 31, 29, 1, 15670.00);
INSERT INTO public.order_items VALUES (19, 7, 6, 1, 1, 4290.00);
INSERT INTO public.order_items VALUES (20, 7, 1, 4, 2, 2190.00);
INSERT INTO public.order_items VALUES (21, 7, 8, 11, 1, 1690.00);
INSERT INTO public.order_items VALUES (22, 8, 28, 34, 1, 25625.00);
INSERT INTO public.order_items VALUES (23, 8, 24, 27, 3, 7890.00);
INSERT INTO public.order_items VALUES (24, 8, 23, 33, 2, 6550.00);
INSERT INTO public.order_items VALUES (25, 9, 2, 16, 1, 2490.00);
INSERT INTO public.order_items VALUES (26, 9, 5, 5, 2, 3190.00);
INSERT INTO public.order_items VALUES (27, 10, 18, 18, 1, 7550.00);
INSERT INTO public.order_items VALUES (28, 10, 15, 21, 1, 7130.00);
INSERT INTO public.order_items VALUES (29, 10, 16, 19, 1, 12340.00);
INSERT INTO public.order_items VALUES (30, 10, 21, 18, 2, 8765.00);


--
-- TOC entry 4977 (class 0 OID 33332)
-- Dependencies: 230
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.orders VALUES (1, 3, '2026-04-02');
INSERT INTO public.orders VALUES (2, 17, '2026-04-05');
INSERT INTO public.orders VALUES (3, 7, '2026-04-08');
INSERT INTO public.orders VALUES (4, 15, '2026-04-12');
INSERT INTO public.orders VALUES (5, 12, '2026-04-18');
INSERT INTO public.orders VALUES (6, 9, '2026-04-22');
INSERT INTO public.orders VALUES (7, 14, '2026-04-25');
INSERT INTO public.orders VALUES (8, 20, '2026-04-28');
INSERT INTO public.orders VALUES (9, 5, '2026-05-05');
INSERT INTO public.orders VALUES (10, 17, '2026-05-08');


--
-- TOC entry 4971 (class 0 OID 33284)
-- Dependencies: 224
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.products VALUES (19, 3, 'Кроссовки белые с оранжевым и красным', 'Топ-Топ', 'Верх — 70% кожа, 30% текстиль, подкладка — текстиль, подошва — резина', 'Многослойный верх из кожи и текстиля. Производитель: Фабрика «Топ-Топ», г. Киров', 9450.00, 'IMG_WS_174110.png');
INSERT INTO public.products VALUES (1, 1, 'Кроссовки детские «Звёздочка» экокожа', 'Малыш-Спорт', 'Верх — экокожа (полиуретан на хлопковой основе), подкладка — хлопок 100%, подошва — ПВХ', 'Кроссовки детские «Звёздочка» экокожа. Производитель: ООО «Малыш-Спорт», г. Смоленск', 2190.00, 'IMG_KS_195217.png');
INSERT INTO public.products VALUES (2, 1, 'Кроссовки детские «Гонщик» экокожа', 'Топ-Топ', 'Верх — экокожа (микрофибра), подкладка — текстиль сетчатый (полиэстер), подошва — термопластичная резина (ТЭП)', 'Кроссовки детские «Гонщик» экокожа. Производитель: Фабрика «Топ-Топ», г. Киров', 2490.00, 'IMG_KS_195213.png');
INSERT INTO public.products VALUES (3, 1, 'Кроссовки детские «Радуга» экокожа перфорированная', 'Лапушка', 'Верх — экокожа перфорированная, вставки — нейлон, стелька — ортопедическая с латексной подушкой, подошва — ЭВА', 'Кроссовки детские «Радуга» экокожа перфорированная. Производитель: ИП Смирнова Л.В. (бренд «Лапушка»), г. Вологда', 1990.00, 'IMG_KS_195222.png');
INSERT INTO public.products VALUES (4, 1, 'Сапожки детские «Снежинка» зимние на меху', 'Тёплые ножки', 'Верх — экокожа морозостойкая, утеплитель — искусственный мех (акрил 70%, полиэстер 30%), подкладка — флис, подошва — термоэластопласт (ТЭП)', 'Сапожки детские «Снежинка» зимние на меху. Производитель: ООО «Тёплые ножки», г. Новосибирск', 3490.00, 'IMG_KB_185501.png');
INSERT INTO public.products VALUES (5, 1, 'Сапожки детские «Медвежонок» демисезонные непромокаемые', 'Северята', 'Верх — плащёвая ткань с водоотталкивающей пропиткой (полиэстер 100%), отделка — экокожа, подкладка — микрофибра, мембрана — AirTex, подошва — резина', 'Сапожки детские «Медвежонок» демисезонные непромокаемые. Производитель: Компания «Северята», г. Архангельск', 3190.00, 'IMG_KB_164816.png');
INSERT INTO public.products VALUES (6, 1, 'Сапожки детские «Принцесса» кожаные', 'Весна', 'Верх — натуральная кожа (КРС), подкладка — шерсть натуральная (70%), байка (30%), стелька — войлочная, подошва — полиуретан', 'Сапожки детские «Принцесса» кожаные. Производитель: Мастерская «Весна», г. Тула', 4290.00, 'IMG_KB_164811.png');
INSERT INTO public.products VALUES (7, 1, 'Сандалии детские «Пчёлка» ортопедические летние', 'Здоровый шаг', 'Верх — нубук натуральный, подкладка — кожа растительного дубления, стелька — анатомическая с супинатором (латекс + пробка), подошва — каучук', 'Сандалии детские «Пчёлка» ортопедические летние. Производитель: ООО «Здоровый шаг», г. Воронеж', 2790.00, 'IMG_KSd_195207.png');
INSERT INTO public.products VALUES (8, 1, 'Сандалии детские «Морячок» текстильные с фиксатором', 'Карапуз', 'Верх — джинсовая ткань (хлопок 100%), окантовка — искусственная кожа, подкладка — хлопок, подошва — ЭВА лёгкая', 'Сандалии детские «Морячок» текстильные с фиксатором. Производитель: ИП Кузнецов А.Д. (бренд «Карапуз»), г. Краснодар', 1690.00, 'IMG_KSd_185508.png');
INSERT INTO public.products VALUES (9, 1, 'Туфли детские «Бантик» лаковые праздничные', 'Маленький франт', 'Верх — искусственная лаковая кожа (ПВХ), носок усиленный — термопластичный полиуретан, подкладка — кожа искусственная дышащая, стелька — анатомическая с амортизацией, подошва — полиуретан', 'Туфли детские «Бантик» лаковые праздничные. Производитель: Дом обуви «Маленький франт», г. Москва', 2390.00, 'IMG_KSho_185512.png');
INSERT INTO public.products VALUES (10, 2, 'Сапоги зимние натуральная кожа', 'Барбари', 'Верх — натуральная кожа, подкладка — евромех, натуральный мех, текстильный утеплитель, подошва — резина', 'Сапоги женские зимние, нескользящая, устойчивая подошва, натуральный мех. Производитель: Дом обуви «Барбари», г. Новороссийск ', 25000.00, 'IMG_WB_170905.png');
INSERT INTO public.products VALUES (11, 2, 'Сапоги осенние натуральная кожа', 'Барбари', 'Верх — натуральная кожа, подкладка — текстильный утеплитель, стелька — текстиль, подошва — ТПР', 'Сапоги женские демисезонные из высококачественной натуральной кожи. Производитель: Дом обуви «Барбари», г. Новороссийск ', 15000.00, 'IMG_WB_170859.png');
INSERT INTO public.products VALUES (12, 2, 'Сапоги трубы демисезонные замшевые', 'Твой комфорт', 'Верх — натуральная замша, утепленные, тракторная подошва, стелька — байка, подошва — резина', 'Сапоги женские демисезонные замшевые. Производитель: ОАО «Твой комфорт», г. Ярославль', 17000.00, 'IMG_WB_170906.png');
INSERT INTO public.products VALUES (13, 2, 'Босоножки «Песчаный берег» коричневые', 'Стиль и комфорт', 'Верх — 100% козья кожа, подкладка — 100% кожа; подошва: 100% кожа', 'Коричневая кожаная модель с открытым носком, боковой пряжкой и закрытым каблуком. Производитель: ИП «Стиль и комфорт», г. Санкт-Петербург', 7500.00, 'IMG_WSd_174332.png');
INSERT INTO public.products VALUES (14, 2, 'Женские босоножки «Черный кофе» со скульптурным каблуком', 'Кожевенные традиции', 'Верх — кожа собственного производств, подкладка — кожа; подошва: резина', 'Открытый носок и ремешок со сборной пряжкой, низкий каблук и резиновая подошва гарантируют комфорт. Производитель: ЗАО «Кожевенные традиции», г. Вятка', 5600.00, 'IMG_WSd_185156.png');
INSERT INTO public.products VALUES (15, 2, 'Босоножки женские «Летний бриз»', 'Модный силуэт', 'Верх — натуральная кожа, подкладка — натуральная кожа, подошва — кожа', 'Босоножки женские кожаные белые, регулируемый ремешок, закрытый каблук и кожаная подошва. Производитель: ООО «Модный силуэт», г. Кострома', 7130.00, 'IMG_WSd_185551.png');
INSERT INTO public.products VALUES (16, 2, 'Демисезонные туфли натуральная кожа', 'Модный силуэт', 'Верх — натуральная овечья кожа, подкладка и стелька — натуральная овечья кожа, подошва — резина', 'Комфортные лаконичные лодочки, классический дизайна с современными акцентами. Производитель: ООО «Модный силуэт», г. Кострома', 12340.00, 'IMG_WSho_174409.png');
INSERT INTO public.products VALUES (17, 2, 'Туфли женские натуральная кожа с металлическими вставками', 'Кожевенные традиции', 'Верх — натуральная телячьей кожа, металлическая пряжка, подкладка и стелька— натуральная овечья кожа, подошва — резина', 'Стильные туфли для весеннего и летнего сезона. Производитель: ЗАО «Кожевенные традиции», г. Вятка', 7757.00, 'IMG_WSho_185202.png');
INSERT INTO public.products VALUES (18, 2, 'Туфли классические лодочки натуральная кожа', 'Стиль и комфорт', 'Верх — натуральная кожа, подкладка и стелька — натуральная кожа, подошва — тунит', 'Модель из натуральной кожи, классический острый носок и изящная шпилька. Производитель: ИП «Стиль и комфорт», г. Санкт-Петербург', 7550.00, 'IMG_WSho_185545.png');
INSERT INTO public.products VALUES (20, 3, 'Кроссовки летние кожаные', 'Топ-Топ', 'Верх — 87% кожа, 11% текстиль, 2% синтетика; подкладка: 100% текстиль; подошва: резина, пластик', 'Уверенность на каждом шагу. Материал обеспечивает долговечность и комфорт при носке. Производитель: Фабрика «Топ-Топ», г. Киров', 8565.00, 'IMG_WS_185528.png');
INSERT INTO public.products VALUES (21, 3, 'Кроссовки кожаные', 'Стиль и комфорт', 'Верх — натуральная кожа, подкладка — кожа, подошва — полиуретан', 'Кроссовки женские из натуральной кожи. Производитель: ИП «Стиль и комфорт», г. Санкт-Петербург', 8765.00, 'IMG_WS_185535.png');
INSERT INTO public.products VALUES (22, 3, 'Кроссовки «Стиль и комфорт»', 'Стиль и комфорт', 'Верх — 70% кожа, 20% полиамид, 10% полиуретан; подкладка — текстиль, подошва — ТПУ', 'Кроссовки женские из натуральной кожи и синтетических материалов, сетчатые вставки. Производитель: ИП «Стиль и комфорт», г. Санкт-Петербург', 7795.00, 'IMG_WS_185538.png');
INSERT INTO public.products VALUES (23, 3, 'Кроссовки для бега «Драйв»', 'Азимут', 'Верх —  сетка, подкладка — текстиль, подошва —  резина', 'Сочетание стиля, комфорта и современных технологий. Производитель: Фабрика «Азимут», г. Санкт-Петербург', 6550.00, 'IMG_MS_185531.png');
INSERT INTO public.products VALUES (24, 3, 'Кроссовки «Азимут Бег» ', 'Азимут', 'Верх — 6% кожа, 29% текстиль, 15% полимерные материалы; подкладка — 100% текстиль; подошва — полимерные материалы, резина', 'Универсальный выбор для повседневного использования. Производитель: Фабрика «Азимут», г. Санкт-Петербург', 7890.00, 'IMG_MS_185532.png');
INSERT INTO public.products VALUES (25, 3, 'Кроссовки', 'Топ-Топ', 'Верх — 56% кожа, 29% текстиль, 15% полимерные материалы; подкладка — 100% текстиль; подошва — полимерные материалы, резина', 'Кроссовки для мужчин, идеальное сочетание стиля и комфорта. Производитель: Фабрика «Топ-Топ», г. Киров', 9567.00, 'IMG_MS_185533.png');
INSERT INTO public.products VALUES (26, 2, 'Черные туфли в классическом стиле — база для деловых образов', 'Барбари', 'Верх — натуральная кожа, подкладка — текстиль, стелька — натуральная кожа, подошва — резина', 'Модель выполнена из натуральной кожи, на резиновой подошве. Производитель: Дом обуви «Барбари», г. Новороссийск ', 24569.00, 'IMG_MSho_190514.png');
INSERT INTO public.products VALUES (27, 3, 'Туфли мужские светлые классика демисезонные', 'Берестов', 'Верх — натуральная кожа, подкладка — текстиль, стелька — натуральная кожа, подошва — ТЭП', 'Туфли на низком каблуке кожаные', 10155.00, 'IMG_MSho_190518.png');
INSERT INTO public.products VALUES (28, 2, 'Туфли из натуральной кожи', 'Берестов', 'Верх — натуральная кожа, подкладка — натуральная кожа, стелька — натуральная кожа, подошва — резина', 'Модель выполнена из натуральной кожи, на резиновой подошве, поддеживает классический и деловой стиль образов. Производитель: Дом обуви «Берестов», г. Москва', 25625.00, 'IMG_MSho_191612.png');
INSERT INTO public.products VALUES (29, 3, 'Ботинки мужские демисезонные', 'Барбари', 'Верх — натуральная кожа, подкладка — текстиль, подошва — искусственный материал', 'Ботинки из натуральной кожи темно-коричневого и черного цвета на шнурках. Производитель: Дом обуви «Берестов», г. Москва', 21500.00, 'IMG_MB_174349.png');
INSERT INTO public.products VALUES (30, 3, 'Ботинки черные из натуральной кожи', 'Кожевенные традиции', 'Верх — натуральная кожа, подкладка — ворсин, стелька — ворсин, подошва — тунит', 'Ботинки представляют баланс традиций и современности. Выполнены из натуральной кожи насыщенного черного цвета. Производитель: ЗАО «Кожевенные традиции», г. Вятка', 14567.00, 'IMG_MB_191200.png');
INSERT INTO public.products VALUES (31, 3, 'Ботинки зимние классические', 'Барбари', 'Верх — натуральная кожа, подкладка — натуральный мех, стелька — натуральный мех, подошва — ТЭП', 'Выбор на каждый день — натуральная кожа, натуральный мех. Производитель: Дом обуви «Барбари», г. Новороссийск ', 15670.00, 'IMG_MB_191205.png');


--
-- TOC entry 4973 (class 0 OID 33301)
-- Dependencies: 226
-- Data for Name: sizes; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sizes VALUES (1, '18');
INSERT INTO public.sizes VALUES (2, '19');
INSERT INTO public.sizes VALUES (3, '20');
INSERT INTO public.sizes VALUES (4, '21');
INSERT INTO public.sizes VALUES (5, '22');
INSERT INTO public.sizes VALUES (6, '23');
INSERT INTO public.sizes VALUES (7, '24');
INSERT INTO public.sizes VALUES (8, '25');
INSERT INTO public.sizes VALUES (9, '26');
INSERT INTO public.sizes VALUES (10, '27');
INSERT INTO public.sizes VALUES (11, '28');
INSERT INTO public.sizes VALUES (12, '29');
INSERT INTO public.sizes VALUES (13, '30');
INSERT INTO public.sizes VALUES (14, '31');
INSERT INTO public.sizes VALUES (15, '32');
INSERT INTO public.sizes VALUES (16, '33');
INSERT INTO public.sizes VALUES (17, '34');
INSERT INTO public.sizes VALUES (18, '35');
INSERT INTO public.sizes VALUES (19, '36');
INSERT INTO public.sizes VALUES (20, '36.5');
INSERT INTO public.sizes VALUES (21, '37');
INSERT INTO public.sizes VALUES (22, '37.5');
INSERT INTO public.sizes VALUES (23, '38');
INSERT INTO public.sizes VALUES (24, '38.5');
INSERT INTO public.sizes VALUES (25, '39');
INSERT INTO public.sizes VALUES (26, '39.5');
INSERT INTO public.sizes VALUES (27, '40');
INSERT INTO public.sizes VALUES (28, '40.5');
INSERT INTO public.sizes VALUES (29, '41');
INSERT INTO public.sizes VALUES (30, '41.5');
INSERT INTO public.sizes VALUES (31, '42');
INSERT INTO public.sizes VALUES (32, '42.5');
INSERT INTO public.sizes VALUES (33, '43');
INSERT INTO public.sizes VALUES (34, '44');
INSERT INTO public.sizes VALUES (35, '45');


--
-- TOC entry 4975 (class 0 OID 33310)
-- Dependencies: 228
-- Data for Name: stock_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.stock_items VALUES (1, 20, 22, 5);
INSERT INTO public.stock_items VALUES (2, 20, 24, 5);
INSERT INTO public.stock_items VALUES (3, 23, 30, 18);
INSERT INTO public.stock_items VALUES (4, 23, 32, 18);


--
-- TOC entry 4967 (class 0 OID 33263)
-- Dependencies: 220
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.users VALUES (1, 'isivanov', 'admin', 'Иванов', 'Иван', 'Сергеевич');
INSERT INTO public.users VALUES (6, 'apopov', 'admin', 'Попов', 'Алексей', 'Николаевич');
INSERT INTO public.users VALUES (11, 'afedorov', 'admin', 'Фёдоров', 'Андрей', 'Максимович');
INSERT INTO public.users VALUES (18, 'rkozlov', 'admin', 'Козлов', 'Роман', 'Олегович');
INSERT INTO public.users VALUES (2, 'papetrov', 'manager', 'Петров', 'Пётр', 'Алексеевич');
INSERT INTO public.users VALUES (4, 'ekuznetsova', 'manager', 'Кузнецова', 'Екатерина', 'Андреевна');
INSERT INTO public.users VALUES (8, 'psokolov', 'manager', 'Соколов', 'Павел', 'Викторович');
INSERT INTO public.users VALUES (10, 'nnovikova', 'manager', 'Новикова', 'Наталья', 'Сергеевна');
INSERT INTO public.users VALUES (13, 'jvolkova', 'manager', 'Волкова', 'Юлия', 'Александровна');
INSERT INTO public.users VALUES (16, 'negorov', 'manager', 'Егоров', 'Никита', 'Денисович');
INSERT INTO public.users VALUES (19, 'vstepanova', 'manager', 'Степанова', 'Виктория', 'Романовна');
INSERT INTO public.users VALUES (3, 'asidorova', 'user', 'Сидорова', 'Анна', 'Дмитриевна');
INSERT INTO public.users VALUES (5, 'dsmirnov', 'user', 'Смирнов', 'Дмитрий', 'Владимирович');
INSERT INTO public.users VALUES (7, 'ovasileva', 'user', 'Васильева', 'Ольга', 'Игоревна');
INSERT INTO public.users VALUES (9, 'tmikhailova', 'user', 'Михайлова', 'Татьяна', 'Юрьевна');
INSERT INTO public.users VALUES (12, 'smorozov', 'user', 'Морозов', 'Сергей', 'Павлович');
INSERT INTO public.users VALUES (14, 'aalekseev', 'user', 'Алексеев', 'Артём', 'Евгеньевич');
INSERT INTO public.users VALUES (15, 'ilebedeva', 'user', 'Лебедева', 'Ирина', 'Владимировна');
INSERT INTO public.users VALUES (17, 'epavlova', 'user', 'Павлова', 'Елена', 'Петровна');
INSERT INTO public.users VALUES (20, 'vnikolaev', 'user', 'Николаев', 'Владимир', 'Иванович');


--
-- TOC entry 4993 (class 0 OID 0)
-- Dependencies: 221
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categories_id_seq', 3, true);


--
-- TOC entry 4994 (class 0 OID 0)
-- Dependencies: 231
-- Name: order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_items_id_seq', 30, true);


--
-- TOC entry 4995 (class 0 OID 0)
-- Dependencies: 229
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_id_seq', 10, true);


--
-- TOC entry 4996 (class 0 OID 0)
-- Dependencies: 223
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.products_id_seq', 31, true);


--
-- TOC entry 4997 (class 0 OID 0)
-- Dependencies: 225
-- Name: sizes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sizes_id_seq', 35, true);


--
-- TOC entry 4998 (class 0 OID 0)
-- Dependencies: 227
-- Name: stock_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stock_items_id_seq', 4, true);


--
-- TOC entry 4999 (class 0 OID 0)
-- Dependencies: 219
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 20, true);


--
-- TOC entry 4799 (class 2606 OID 33282)
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- TOC entry 4811 (class 2606 OID 33355)
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- TOC entry 4809 (class 2606 OID 33340)
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- TOC entry 4801 (class 2606 OID 33294)
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- TOC entry 4803 (class 2606 OID 33308)
-- Name: sizes sizes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sizes
    ADD CONSTRAINT sizes_pkey PRIMARY KEY (id);


--
-- TOC entry 4805 (class 2606 OID 33318)
-- Name: stock_items stock_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_items
    ADD CONSTRAINT stock_items_pkey PRIMARY KEY (id);


--
-- TOC entry 4807 (class 2606 OID 33320)
-- Name: stock_items stock_items_product_id_size_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_items
    ADD CONSTRAINT stock_items_product_id_size_id_key UNIQUE (product_id, size_id);


--
-- TOC entry 4795 (class 2606 OID 33273)
-- Name: users users_login_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_login_key UNIQUE (login);


--
-- TOC entry 4797 (class 2606 OID 33271)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4816 (class 2606 OID 33356)
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- TOC entry 4817 (class 2606 OID 33361)
-- Name: order_items order_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- TOC entry 4818 (class 2606 OID 33366)
-- Name: order_items order_items_size_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_size_id_fkey FOREIGN KEY (size_id) REFERENCES public.sizes(id) ON DELETE CASCADE;


--
-- TOC entry 4815 (class 2606 OID 33341)
-- Name: orders orders_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- TOC entry 4812 (class 2606 OID 33295)
-- Name: products products_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE SET NULL;


--
-- TOC entry 4813 (class 2606 OID 33321)
-- Name: stock_items stock_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_items
    ADD CONSTRAINT stock_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- TOC entry 4814 (class 2606 OID 33326)
-- Name: stock_items stock_items_size_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_items
    ADD CONSTRAINT stock_items_size_id_fkey FOREIGN KEY (size_id) REFERENCES public.sizes(id) ON DELETE CASCADE;


-- Completed on 2026-10-24 19:14:57

--
-- PostgreSQL database dump complete
--

\unrestrict ZgeZx0D9zbbfFM6mwr2fSlxHhgjzGVkOMifMXKeZLcKNNJ2OPyaGdgmx8HZbnWp

