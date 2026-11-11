-- =====================================================================
-- Esquema SQLite para Aplicación Móvil ('Food Store')
-- Motor: SQLite 3+
-- =====================================================================

-- 1. Tabla Clientes (Mobile)
CREATE TABLE clientes (
    cliente_id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    apellido TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    telefono TEXT,
    direccion TEXT,
    fecha_registro TEXT NOT NULL DEFAULT (strftime('%Y-%m-%d %H:%M:%f', 'now')),
    activo INTEGER NOT NULL DEFAULT 1 -- SQLite usa INTEGER (0 o 1) para BOOLEAN
);

-- 2. Tabla Productos (Mobile - Catálogo local offline)
CREATE TABLE productos (
    producto_id INTEGER PRIMARY KEY AUTOINCREMENT,
    categoria_id INTEGER NOT NULL,
    nombre TEXT NOT NULL,
    descripcion TEXT,
    precio REAL NOT NULL,
    stock INTEGER NOT NULL DEFAULT 0,
    disponible INTEGER NOT NULL DEFAULT 1,
    imagen_url TEXT,
    activo INTEGER NOT NULL DEFAULT 1,
    CONSTRAINT chk_producto_precio CHECK (precio > 0),
    CONSTRAINT chk_producto_stock CHECK (stock >= 0)
);

-- 3. Tabla Pedidos (Mobile - Órdenes generadas offline)
CREATE TABLE pedidos (
    pedido_id INTEGER PRIMARY KEY AUTOINCREMENT,
    cliente_id INTEGER NOT NULL,
    metodopago_id INTEGER NOT NULL,
    fecha_pedido TEXT NOT NULL DEFAULT (strftime('%Y-%m-%d %H:%M:%f', 'now')),
    estado TEXT NOT NULL DEFAULT 'PENDIENTE' CHECK(estado IN ('PENDIENTE', 'EN_PREPARACION', 'ENTREGADO', 'CANCELADO')),
    total REAL NOT NULL,
    -- Columna adicional recomendada para control de sincronización con el servidor
    sincronizado INTEGER NOT NULL DEFAULT 0, 
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (cliente_id) 
        REFERENCES clientes(cliente_id) 
        ON DELETE RESTRICT
    CONSTRAINT chk_pedido_total CHECK (total >= 0)
);

-- Índices recomendados para consultas móviles eficientes
CREATE INDEX idx_mobile_productos_cat ON productos(categoria_id);
CREATE INDEX idx_mobile_pedidos_cliente ON pedidos(cliente_id);