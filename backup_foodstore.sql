--
-- PostgreSQL database dump
--

\restrict ga2WAKyd0JLI76bhMbsQzxNHDXjKpHNtZJsKDoCDedQzKXQbp2rhWp9K89SKcpb

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

-- Started on 2026-11-11 18:29:28

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

--
-- TOC entry 868 (class 1247 OID 16529)
-- Name: estado_pedido_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.estado_pedido_enum AS ENUM (
    'PENDIENTE',
    'EN_PREPARACION',
    'ENTREGADO',
    'CANCELADO'
);


ALTER TYPE public.estado_pedido_enum OWNER TO postgres;

--
-- TOC entry 235 (class 1255 OID 16699)
-- Name: fn_registrar_auditoria(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_registrar_auditoria() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO auditoria_operaciones (usuario, tabla_afectada, operacion, datos_previos)
        VALUES (current_user, TG_TABLE_NAME, 'DELETE', to_jsonb(OLD));
        RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO auditoria_operaciones (usuario, tabla_afectada, operacion, datos_previos)
        VALUES (current_user, TG_TABLE_NAME, 'UPDATE', to_jsonb(OLD));
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$;


ALTER FUNCTION public.fn_registrar_auditoria() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 234 (class 1259 OID 16686)
-- Name: auditoria_operaciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auditoria_operaciones (
    auditoria_id integer NOT NULL,
    usuario character varying(100) NOT NULL,
    tabla_afectada character varying(100) NOT NULL,
    operacion character varying(20) NOT NULL,
    fecha timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    datos_previos jsonb
);


ALTER TABLE public.auditoria_operaciones OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 16685)
-- Name: auditoria_operaciones_auditoria_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.auditoria_operaciones ALTER COLUMN auditoria_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.auditoria_operaciones_auditoria_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 222 (class 1259 OID 16556)
-- Name: categorias; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categorias (
    categoria_id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    descripcion text
);


ALTER TABLE public.categorias OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16555)
-- Name: categorias_categoria_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.categorias ALTER COLUMN categoria_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.categorias_categoria_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 220 (class 1259 OID 16538)
-- Name: clientes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clientes (
    cliente_id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    apellido character varying(100) NOT NULL,
    email character varying(150) NOT NULL,
    telefono character varying(20),
    direccion text,
    fecha_registro timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    activo boolean DEFAULT true NOT NULL
);


ALTER TABLE public.clientes OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16537)
-- Name: clientes_cliente_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.clientes ALTER COLUMN cliente_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.clientes_cliente_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 230 (class 1259 OID 16630)
-- Name: detalle_pedidos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.detalle_pedidos (
    detalle_id integer NOT NULL,
    pedido_id integer NOT NULL,
    producto_id integer NOT NULL,
    cantidad integer NOT NULL,
    precio_unitario numeric(10,2) NOT NULL,
    CONSTRAINT chk_detalle_cantidad CHECK ((cantidad > 0)),
    CONSTRAINT chk_detalle_precio CHECK ((precio_unitario > (0)::numeric))
);


ALTER TABLE public.detalle_pedidos OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16629)
-- Name: detalle_pedidos_detalle_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.detalle_pedidos ALTER COLUMN detalle_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.detalle_pedidos_detalle_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 226 (class 1259 OID 16593)
-- Name: metodos_pago; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.metodos_pago (
    metodopago_id integer NOT NULL,
    nombre character varying(50) NOT NULL,
    activo boolean DEFAULT true NOT NULL
);


ALTER TABLE public.metodos_pago OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16592)
-- Name: metodos_pago_metodopago_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.metodos_pago ALTER COLUMN metodopago_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.metodos_pago_metodopago_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 228 (class 1259 OID 16605)
-- Name: pedidos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pedidos (
    pedido_id integer NOT NULL,
    cliente_id integer NOT NULL,
    metodopago_id integer NOT NULL,
    fecha_pedido timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    estado public.estado_pedido_enum DEFAULT 'PENDIENTE'::public.estado_pedido_enum NOT NULL,
    total numeric(10,2) NOT NULL,
    CONSTRAINT chk_pedido_total CHECK ((total >= (0)::numeric))
);


ALTER TABLE public.pedidos OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16604)
-- Name: pedidos_pedido_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.pedidos ALTER COLUMN pedido_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.pedidos_pedido_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 224 (class 1259 OID 16568)
-- Name: productos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.productos (
    producto_id integer NOT NULL,
    categoria_id integer NOT NULL,
    nombre character varying(150) NOT NULL,
    descripcion text,
    precio numeric(10,2) NOT NULL,
    stock integer DEFAULT 0 NOT NULL,
    disponible boolean DEFAULT true NOT NULL,
    imagen_url character varying(255),
    activo boolean DEFAULT true NOT NULL,
    CONSTRAINT chk_producto_precio CHECK ((precio > (0)::numeric)),
    CONSTRAINT chk_producto_stock CHECK ((stock >= 0))
);


ALTER TABLE public.productos OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16567)
-- Name: productos_producto_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.productos ALTER COLUMN producto_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.productos_producto_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 232 (class 1259 OID 16657)
-- Name: ventas_historicas_planas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ventas_historicas_planas (
    venta_hist_id integer NOT NULL,
    cliente_nombre character varying(100) NOT NULL,
    cliente_apellido character varying(100) NOT NULL,
    cliente_email character varying(150) NOT NULL,
    cliente_telefono character varying(20),
    cliente_direccion text,
    fecha_pedido timestamp with time zone NOT NULL,
    estado_pedido character varying(30) NOT NULL,
    metodo_pago character varying(50) NOT NULL,
    producto_nombre character varying(150) NOT NULL,
    producto_descripcion text,
    categoria_nombre character varying(100) NOT NULL,
    categoria_descripcion text,
    cantidad integer NOT NULL,
    precio_unitario numeric(10,2) NOT NULL,
    subtotal numeric(10,2) NOT NULL
);


ALTER TABLE public.ventas_historicas_planas OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16656)
-- Name: ventas_historicas_planas_venta_hist_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.ventas_historicas_planas ALTER COLUMN venta_hist_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ventas_historicas_planas_venta_hist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 5003 (class 0 OID 16686)
-- Dependencies: 234
-- Data for Name: auditoria_operaciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auditoria_operaciones (auditoria_id, usuario, tabla_afectada, operacion, fecha, datos_previos) FROM stdin;
\.


--
-- TOC entry 4991 (class 0 OID 16556)
-- Dependencies: 222
-- Data for Name: categorias; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categorias (categoria_id, nombre, descripcion) FROM stdin;
6	Postres	Helados, tortas, flanes y dulces artesanales.
7	Platos Principales	Carnes, pastas y minutas elaboradas.
8	Bebidas	Gaseosas, jugos naturales, cervezas y aguas.
9	Ensaladas	Opciones saludables, frescas y ligeras.
10	Comida Rápida	Hamburguesas, papas fritas, pizzas y antojitos rápidos.
\.


--
-- TOC entry 4989 (class 0 OID 16538)
-- Dependencies: 220
-- Data for Name: clientes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.clientes (cliente_id, nombre, apellido, email, telefono, direccion, fecha_registro, activo) FROM stdin;
6	Lucas	Rodríguez	lucas.rodriguez@email.com	+5491155555555	Mitre 654, La Plata	2026-01-28 21:15:00-03	t
7	Juan	Pérez	juan.perez@email.com	+5491155551111	Av. Corrientes 1234, CABA	2026-01-12 13:20:00-03	t
8	María	Gómez	maria.gomez@email.com	+5491155552222	Belgrano 456, Córdoba	2026-01-15 21:00:00-03	t
9	Ana	Martínez	ana.martinez@email.com	+5491155554444	Rivadavia 321, Rosario	2026-01-22 20:30:00-03	t
10	Carlos	López	carlos.lopez@email.com	+5491155553333	San Martín 789, Mendoza	2026-01-18 14:10:00-03	t
\.


--
-- TOC entry 4999 (class 0 OID 16630)
-- Dependencies: 230
-- Data for Name: detalle_pedidos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.detalle_pedidos (detalle_id, pedido_id, producto_id, cantidad, precio_unitario) FROM stdin;
11	7	13	1	2800.00
12	7	15	1	7800.00
13	8	12	1	3800.00
14	8	11	1	9500.00
15	9	20	1	5500.00
16	10	19	1	2200.00
17	10	17	1	8500.00
18	11	16	1	1800.00
19	11	18	1	12500.00
20	12	14	1	11500.00
\.


--
-- TOC entry 4995 (class 0 OID 16593)
-- Dependencies: 226
-- Data for Name: metodos_pago; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.metodos_pago (metodopago_id, nombre, activo) FROM stdin;
5	Efectivo	t
6	MercadoPago	t
7	Tarjeta de Crédito	t
8	Tarjeta de Débito	t
\.


--
-- TOC entry 4997 (class 0 OID 16605)
-- Dependencies: 228
-- Data for Name: pedidos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pedidos (pedido_id, cliente_id, metodopago_id, fecha_pedido, estado, total) FROM stdin;
7	9	6	2026-01-22 20:30:00-03	ENTREGADO	10600.00
8	6	7	2026-01-28 21:15:00-03	ENTREGADO	13300.00
9	7	5	2026-01-25 12:45:00-03	CANCELADO	5500.00
10	7	5	2026-01-12 13:20:00-03	ENTREGADO	10700.00
11	8	7	2026-01-15 21:00:00-03	ENTREGADO	14300.00
12	10	8	2026-01-18 14:10:00-03	ENTREGADO	11500.00
\.


--
-- TOC entry 4993 (class 0 OID 16568)
-- Dependencies: 224
-- Data for Name: productos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.productos (producto_id, categoria_id, nombre, descripcion, precio, stock, disponible, imagen_url, activo) FROM stdin;
11	6	Helado de Chocolate Suizo (1kg)	Helado artesanal de chocolate con almendras.	9500.00	50	t	\N	t
12	6	Flan Casero con Dulce de Leche	Tradicional flan de huevo con dulce de leche colonial.	3800.00	50	t	\N	t
13	8	Limonada con Menta y Jengibre	Jugo natural de limón exprimido.	2800.00	50	t	\N	t
14	10	Hamburguesa Doble Bacon	Doble carne, doble cheddar, panceta crujiente y salsa BBQ.	11500.00	50	t	\N	t
15	9	Ensalada Caesar con Pollo	Lechuga romana, picatostes, parmesano, aderezo Caesar y pollo grillado.	7800.00	50	t	\N	t
16	8	Agua Mineral 500ml	Agua sin gas.	1800.00	50	t	\N	t
17	10	Hamburguesa Clásica con Queso	Medallón de carne 150g, cheddar, lechuga y tomate.	8500.00	50	t	\N	t
18	7	Milanesa a la Napolitana con Papas	Suprema de pollo con salsa de tomate, jamón, muzzarella y papas fritas.	12500.00	50	t	\N	t
19	8	Coca-Cola 500ml	Bebida gaseosa sabor cola bien fría.	2200.00	50	t	\N	t
20	10	Papas Fritas Cheddar y Panceta	Porción grande de papas fritas con salsa cheddar y bacon.	5500.00	50	t	\N	t
\.


--
-- TOC entry 5001 (class 0 OID 16657)
-- Dependencies: 232
-- Data for Name: ventas_historicas_planas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ventas_historicas_planas (venta_hist_id, cliente_nombre, cliente_apellido, cliente_email, cliente_telefono, cliente_direccion, fecha_pedido, estado_pedido, metodo_pago, producto_nombre, producto_descripcion, categoria_nombre, categoria_descripcion, cantidad, precio_unitario, subtotal) FROM stdin;
1	Juan	Pérez	juan.perez@email.com	+5491155551111	Av. Corrientes 1234, CABA	2026-01-12 13:20:00-03	ENTREGADO	Efectivo	Hamburguesa Clásica con Queso	Medallón de carne 150g, cheddar, lechuga y tomate.	Comida Rápida	Hamburguesas, papas fritas, pizzas y antojitos rápidos.	1	8500.00	8500.00
2	Juan	Pérez	juan.perez@email.com	+5491155551111	Av. Corrientes 1234, CABA	2026-01-12 13:20:00-03	ENTREGADO	Efectivo	Coca-Cola 500ml	Bebida gaseosa sabor cola bien fría.	Bebidas	Gaseosas, jugos naturales, cervezas y aguas.	1	2200.00	2200.00
3	María	Gómez	maria.gomez@email.com	+5491155552222	Belgrano 456, Córdoba	2026-01-15 21:00:00-03	ENTREGADO	Tarjeta de Crédito	Milanesa a la Napolitana con Papas	Suprema de pollo con salsa de tomate, jamón, muzzarella y papas fritas.	Platos Principales	Carnes, pastas y minutas elaboradas.	1	12500.00	12500.00
4	María	Gómez	maria.gomez@email.com	+5491155552222	Belgrano 456, Córdoba	2026-01-15 21:00:00-03	ENTREGADO	Tarjeta de Crédito	Agua Mineral 500ml	Agua sin gas.	Bebidas	Gaseosas, jugos naturales, cervezas y aguas.	1	1800.00	1800.00
5	Carlos	López	carlos.lopez@email.com	+5491155553333	San Martín 789, Mendoza	2026-01-18 14:10:00-03	ENTREGADO	Tarjeta de Débito	Hamburguesa Doble Bacon	Doble carne, doble cheddar, panceta crujiente y salsa BBQ.	Comida Rápida	Hamburguesas, papas fritas, pizzas y antojitos rápidos.	1	11500.00	11500.00
6	Ana	Martínez	ana.martinez@email.com	+5491155554444	Rivadavia 321, Rosario	2026-01-22 20:30:00-03	ENTREGADO	MercadoPago	Ensalada Caesar con Pollo	Lechuga romana, picatostes, parmesano, aderezo Caesar y pollo grillado.	Ensaladas	Opciones saludables, frescas y ligeras.	1	7800.00	7800.00
7	Ana	Martínez	ana.martinez@email.com	+5491155554444	Rivadavia 321, Rosario	2026-01-22 20:30:00-03	ENTREGADO	MercadoPago	Limonada con Menta y Jengibre	Jugo natural de limón exprimido.	Bebidas	Gaseosas, jugos naturales, cervezas y aguas.	1	2800.00	2800.00
8	Juan	Pérez	juan.perez@email.com	+5491155551111	Av. Corrientes 1234, CABA	2026-01-25 12:45:00-03	CANCELADO	Efectivo	Papas Fritas Cheddar y Panceta	Porción grande de papas fritas con salsa cheddar y bacon.	Comida Rápida	Hamburguesas, papas fritas, pizzas y antojitos rápidos.	1	5500.00	5500.00
9	Lucas	Rodríguez	lucas.rodriguez@email.com	+5491155555555	Mitre 654, La Plata	2026-01-28 21:15:00-03	ENTREGADO	Tarjeta de Crédito	Helado de Chocolate Suizo (1kg)	Helado artesanal de chocolate con almendras.	Postres	Helados, tortas, flanes y dulces artesanales.	1	9500.00	9500.00
10	Lucas	Rodríguez	lucas.rodriguez@email.com	+5491155555555	Mitre 654, La Plata	2026-01-28 21:15:00-03	ENTREGADO	Tarjeta de Crédito	Flan Casero con Dulce de Leche	Tradicional flan de huevo con dulce de leche colonial.	Postres	Helados, tortas, flanes y dulces artesanales.	1	3800.00	3800.00
\.


--
-- TOC entry 5023 (class 0 OID 0)
-- Dependencies: 233
-- Name: auditoria_operaciones_auditoria_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auditoria_operaciones_auditoria_id_seq', 1, false);


--
-- TOC entry 5024 (class 0 OID 0)
-- Dependencies: 221
-- Name: categorias_categoria_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categorias_categoria_id_seq', 10, true);


--
-- TOC entry 5025 (class 0 OID 0)
-- Dependencies: 219
-- Name: clientes_cliente_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.clientes_cliente_id_seq', 10, true);


--
-- TOC entry 5026 (class 0 OID 0)
-- Dependencies: 229
-- Name: detalle_pedidos_detalle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.detalle_pedidos_detalle_id_seq', 20, true);


--
-- TOC entry 5027 (class 0 OID 0)
-- Dependencies: 225
-- Name: metodos_pago_metodopago_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.metodos_pago_metodopago_id_seq', 8, true);


--
-- TOC entry 5028 (class 0 OID 0)
-- Dependencies: 227
-- Name: pedidos_pedido_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pedidos_pedido_id_seq', 12, true);


--
-- TOC entry 5029 (class 0 OID 0)
-- Dependencies: 223
-- Name: productos_producto_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.productos_producto_id_seq', 20, true);


--
-- TOC entry 5030 (class 0 OID 0)
-- Dependencies: 231
-- Name: ventas_historicas_planas_venta_hist_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ventas_historicas_planas_venta_hist_id_seq', 10, true);


--
-- TOC entry 4833 (class 2606 OID 16698)
-- Name: auditoria_operaciones auditoria_operaciones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditoria_operaciones
    ADD CONSTRAINT auditoria_operaciones_pkey PRIMARY KEY (auditoria_id);


--
-- TOC entry 4813 (class 2606 OID 16566)
-- Name: categorias categorias_nombre_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categorias
    ADD CONSTRAINT categorias_nombre_key UNIQUE (nombre);


--
-- TOC entry 4815 (class 2606 OID 16564)
-- Name: categorias categorias_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categorias
    ADD CONSTRAINT categorias_pkey PRIMARY KEY (categoria_id);


--
-- TOC entry 4809 (class 2606 OID 16554)
-- Name: clientes clientes_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_email_key UNIQUE (email);


--
-- TOC entry 4811 (class 2606 OID 16552)
-- Name: clientes clientes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_pkey PRIMARY KEY (cliente_id);


--
-- TOC entry 4828 (class 2606 OID 16641)
-- Name: detalle_pedidos detalle_pedidos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalle_pedidos
    ADD CONSTRAINT detalle_pedidos_pkey PRIMARY KEY (detalle_id);


--
-- TOC entry 4820 (class 2606 OID 16603)
-- Name: metodos_pago metodos_pago_nombre_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.metodos_pago
    ADD CONSTRAINT metodos_pago_nombre_key UNIQUE (nombre);


--
-- TOC entry 4822 (class 2606 OID 16601)
-- Name: metodos_pago metodos_pago_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.metodos_pago
    ADD CONSTRAINT metodos_pago_pkey PRIMARY KEY (metodopago_id);


--
-- TOC entry 4826 (class 2606 OID 16618)
-- Name: pedidos pedidos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedidos
    ADD CONSTRAINT pedidos_pkey PRIMARY KEY (pedido_id);


--
-- TOC entry 4818 (class 2606 OID 16586)
-- Name: productos productos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_pkey PRIMARY KEY (producto_id);


--
-- TOC entry 4831 (class 2606 OID 16675)
-- Name: ventas_historicas_planas ventas_historicas_planas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas_historicas_planas
    ADD CONSTRAINT ventas_historicas_planas_pkey PRIMARY KEY (venta_hist_id);


--
-- TOC entry 4829 (class 1259 OID 16655)
-- Name: idx_detalle_pedidos_pedido; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_detalle_pedidos_pedido ON public.detalle_pedidos USING btree (pedido_id);


--
-- TOC entry 4823 (class 1259 OID 16653)
-- Name: idx_pedidos_cliente; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_pedidos_cliente ON public.pedidos USING btree (cliente_id);


--
-- TOC entry 4824 (class 1259 OID 16654)
-- Name: idx_pedidos_estado; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_pedidos_estado ON public.pedidos USING btree (estado);


--
-- TOC entry 4816 (class 1259 OID 16652)
-- Name: idx_productos_categoria; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_productos_categoria ON public.productos USING btree (categoria_id);


--
-- TOC entry 4839 (class 2620 OID 16700)
-- Name: clientes trg_auditar_clientes; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_auditar_clientes AFTER DELETE OR UPDATE ON public.clientes FOR EACH ROW EXECUTE FUNCTION public.fn_registrar_auditoria();


--
-- TOC entry 4840 (class 2620 OID 16701)
-- Name: pedidos trg_auditar_pedidos; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_auditar_pedidos AFTER DELETE OR UPDATE ON public.pedidos FOR EACH ROW EXECUTE FUNCTION public.fn_registrar_auditoria();


--
-- TOC entry 4837 (class 2606 OID 16642)
-- Name: detalle_pedidos fk_detalle_pedido; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalle_pedidos
    ADD CONSTRAINT fk_detalle_pedido FOREIGN KEY (pedido_id) REFERENCES public.pedidos(pedido_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4838 (class 2606 OID 16647)
-- Name: detalle_pedidos fk_detalle_producto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalle_pedidos
    ADD CONSTRAINT fk_detalle_producto FOREIGN KEY (producto_id) REFERENCES public.productos(producto_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 4835 (class 2606 OID 16619)
-- Name: pedidos fk_pedido_cliente; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedidos
    ADD CONSTRAINT fk_pedido_cliente FOREIGN KEY (cliente_id) REFERENCES public.clientes(cliente_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 4836 (class 2606 OID 16624)
-- Name: pedidos fk_pedido_metodopago; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedidos
    ADD CONSTRAINT fk_pedido_metodopago FOREIGN KEY (metodopago_id) REFERENCES public.metodos_pago(metodopago_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 4834 (class 2606 OID 16587)
-- Name: productos fk_producto_categoria; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT fk_producto_categoria FOREIGN KEY (categoria_id) REFERENCES public.categorias(categoria_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 5009 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE categorias; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.categorias TO rol_admin;
GRANT SELECT,INSERT,UPDATE ON TABLE public.categorias TO rol_app_backend;
GRANT SELECT ON TABLE public.categorias TO rol_auditor;


--
-- TOC entry 5010 (class 0 OID 0)
-- Dependencies: 221
-- Name: SEQUENCE categorias_categoria_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.categorias_categoria_id_seq TO rol_admin;
GRANT SELECT,USAGE ON SEQUENCE public.categorias_categoria_id_seq TO rol_app_backend;


--
-- TOC entry 5011 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE clientes; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.clientes TO rol_admin;
GRANT SELECT,INSERT,UPDATE ON TABLE public.clientes TO rol_app_backend;
GRANT SELECT ON TABLE public.clientes TO rol_auditor;


--
-- TOC entry 5012 (class 0 OID 0)
-- Dependencies: 219
-- Name: SEQUENCE clientes_cliente_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.clientes_cliente_id_seq TO rol_admin;
GRANT SELECT,USAGE ON SEQUENCE public.clientes_cliente_id_seq TO rol_app_backend;


--
-- TOC entry 5013 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE detalle_pedidos; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.detalle_pedidos TO rol_admin;
GRANT SELECT,INSERT,UPDATE ON TABLE public.detalle_pedidos TO rol_app_backend;
GRANT SELECT ON TABLE public.detalle_pedidos TO rol_auditor;


--
-- TOC entry 5014 (class 0 OID 0)
-- Dependencies: 229
-- Name: SEQUENCE detalle_pedidos_detalle_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.detalle_pedidos_detalle_id_seq TO rol_admin;
GRANT SELECT,USAGE ON SEQUENCE public.detalle_pedidos_detalle_id_seq TO rol_app_backend;


--
-- TOC entry 5015 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE metodos_pago; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.metodos_pago TO rol_admin;
GRANT SELECT,INSERT,UPDATE ON TABLE public.metodos_pago TO rol_app_backend;
GRANT SELECT ON TABLE public.metodos_pago TO rol_auditor;


--
-- TOC entry 5016 (class 0 OID 0)
-- Dependencies: 225
-- Name: SEQUENCE metodos_pago_metodopago_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.metodos_pago_metodopago_id_seq TO rol_admin;
GRANT SELECT,USAGE ON SEQUENCE public.metodos_pago_metodopago_id_seq TO rol_app_backend;


--
-- TOC entry 5017 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE pedidos; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.pedidos TO rol_admin;
GRANT SELECT,INSERT,UPDATE ON TABLE public.pedidos TO rol_app_backend;
GRANT SELECT ON TABLE public.pedidos TO rol_auditor;


--
-- TOC entry 5018 (class 0 OID 0)
-- Dependencies: 227
-- Name: SEQUENCE pedidos_pedido_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.pedidos_pedido_id_seq TO rol_admin;
GRANT SELECT,USAGE ON SEQUENCE public.pedidos_pedido_id_seq TO rol_app_backend;


--
-- TOC entry 5019 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE productos; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.productos TO rol_admin;
GRANT SELECT,INSERT,UPDATE ON TABLE public.productos TO rol_app_backend;
GRANT SELECT ON TABLE public.productos TO rol_auditor;


--
-- TOC entry 5020 (class 0 OID 0)
-- Dependencies: 223
-- Name: SEQUENCE productos_producto_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.productos_producto_id_seq TO rol_admin;
GRANT SELECT,USAGE ON SEQUENCE public.productos_producto_id_seq TO rol_app_backend;


--
-- TOC entry 5021 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE ventas_historicas_planas; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.ventas_historicas_planas TO rol_admin;
GRANT SELECT ON TABLE public.ventas_historicas_planas TO rol_auditor;


--
-- TOC entry 5022 (class 0 OID 0)
-- Dependencies: 231
-- Name: SEQUENCE ventas_historicas_planas_venta_hist_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.ventas_historicas_planas_venta_hist_id_seq TO rol_admin;
GRANT SELECT,USAGE ON SEQUENCE public.ventas_historicas_planas_venta_hist_id_seq TO rol_app_backend;


-- Completed on 2026-11-11 18:29:29

--
-- PostgreSQL database dump complete
--

\unrestrict ga2WAKyd0JLI76bhMbsQzxNHDXjKpHNtZJsKDoCDedQzKXQbp2rhWp9K89SKcpb

