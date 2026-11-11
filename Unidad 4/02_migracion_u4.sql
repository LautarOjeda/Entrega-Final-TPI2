-- =====================================================================
-- 2. Script DML: Inserción de 10 registros de prueba (con redundancias y repeticiones)
-- =====================================================================
-- Evidencia clientes repetidos (Juan Pérez, María Gómez) y métodos/categorías repetidos.

INSERT INTO ventas_historicas_planas (
    cliente_nombre, cliente_apellido, cliente_email, cliente_telefono, cliente_direccion,
    fecha_pedido, estado_pedido, metodo_pago,
    producto_nombre, producto_descripcion, categoria_nombre, categoria_descripcion,
    cantidad, precio_unitario, subtotal
) VALUES
-- Pedido 1 de Juan Pérez
('Juan', 'Pérez', 'juan.perez@email.com', '+5491155551111', 'Av. Corrientes 1234, CABA', 
 '2026-01-12 13:20:00-03', 'ENTREGADO', 'Efectivo',
 'Hamburguesa Clásica con Queso', 'Medallón de carne 150g, cheddar, lechuga y tomate.', 'Comida Rápida', 'Hamburguesas, papas fritas, pizzas y antojitos rápidos.',
 1, 8500.00, 8500.00),

-- Pedido 1 (cont. ítem 2 de Juan Pérez)
('Juan', 'Pérez', 'juan.perez@email.com', '+5491155551111', 'Av. Corrientes 1234, CABA', 
 '2026-01-12 13:20:00-03', 'ENTREGADO', 'Efectivo',
 'Coca-Cola 500ml', 'Bebida gaseosa sabor cola bien fría.', 'Bebidas', 'Gaseosas, jugos naturales, cervezas y aguas.',
 1, 2200.00, 2200.00),

-- Pedido 2 de María Gómez
('María', 'Gómez', 'maria.gomez@email.com', '+5491155552222', 'Belgrano 456, Córdoba', 
 '2026-01-15 21:00:00-03', 'ENTREGADO', 'Tarjeta de Crédito',
 'Milanesa a la Napolitana con Papas', 'Suprema de pollo con salsa de tomate, jamón, muzzarella y papas fritas.', 'Platos Principales', 'Carnes, pastas y minutas elaboradas.',
 1, 12500.00, 12500.00),

-- Pedido 2 (cont. ítem 2 de María Gómez)
('María', 'Gómez', 'maria.gomez@email.com', '+5491155552222', 'Belgrano 456, Córdoba', 
 '2026-01-15 21:00:00-03', 'ENTREGADO', 'Tarjeta de Crédito',
 'Agua Mineral 500ml', 'Agua sin gas.', 'Bebidas', 'Gaseosas, jugos naturales, cervezas y aguas.',
 1, 1800.00, 1800.00),

-- Pedido 3 de Carlos López
('Carlos', 'López', 'carlos.lopez@email.com', '+5491155553333', 'San Martín 789, Mendoza', 
 '2026-01-18 14:10:00-03', 'ENTREGADO', 'Tarjeta de Débito',
 'Hamburguesa Doble Bacon', 'Doble carne, doble cheddar, panceta crujiente y salsa BBQ.', 'Comida Rápida', 'Hamburguesas, papas fritas, pizzas y antojitos rápidos.',
 1, 11500.00, 11500.00),

-- Pedido 4 de Ana Martínez (Cliente repetido en otra transacción histórica)
('Ana', 'Martínez', 'ana.martinez@email.com', '+5491155554444', 'Rivadavia 321, Rosario', 
 '2026-01-22 20:30:00-03', 'ENTREGADO', 'MercadoPago',
 'Ensalada Caesar con Pollo', 'Lechuga romana, picatostes, parmesano, aderezo Caesar y pollo grillado.', 'Ensaladas', 'Opciones saludables, frescas y ligeras.',
 1, 7800.00, 7800.00),

-- Pedido 4 (cont. ítem 2 de Ana Martínez)
('Ana', 'Martínez', 'ana.martinez@email.com', '+5491155554444', 'Rivadavia 321, Rosario', 
 '2026-01-22 20:30:00-03', 'ENTREGADO', 'MercadoPago',
 'Limonada con Menta y Jengibre', 'Jugo natural de limón exprimido.', 'Bebidas', 'Gaseosas, jugos naturales, cervezas y aguas.',
 1, 2800.00, 2800.00),

-- Pedido 5 de Juan Pérez (Mismo cliente Juan Pérez comprando nuevamente)
('Juan', 'Pérez', 'juan.perez@email.com', '+5491155551111', 'Av. Corrientes 1234, CABA', 
 '2026-01-25 12:45:00-03', 'CANCELADO', 'Efectivo',
 'Papas Fritas Cheddar y Panceta', 'Porción grande de papas fritas con salsa cheddar y bacon.', 'Comida Rápida', 'Hamburguesas, papas fritas, pizzas y antojitos rápidos.',
 1, 5500.00, 5500.00),

-- Pedido 6 de Lucas Rodríguez
('Lucas', 'Rodríguez', 'lucas.rodriguez@email.com', '+5491155555555', 'Mitre 654, La Plata', 
 '2026-01-28 21:15:00-03', 'ENTREGADO', 'Tarjeta de Crédito',
 'Helado de Chocolate Suizo (1kg)', 'Helado artesanal de chocolate con almendras.', 'Postres', 'Helados, tortas, flanes y dulces artesanales.',
 1, 9500.00, 9500.00),

-- Pedido 6 (cont. ítem 2 de Lucas Rodríguez)
('Lucas', 'Rodríguez', 'lucas.rodriguez@email.com', '+5491155555555', 'Mitre 654, La Plata', 
 '2026-01-28 21:15:00-03', 'ENTREGADO', 'Tarjeta de Crédito',
 'Flan Casero con Dulce de Leche', 'Tradicional flan de huevo con dulce de leche colonial.', 'Postres', 'Helados, tortas, flanes y dulces artesanales.',
 1, 3800.00, 3800.00);


-- =====================================================================
-- 3. Script SQL de Migración sin Pérdida (Transaccional y Reversible)
-- =====================================================================
/* 
   PLAN DE REVERSIÓN (ROLLBACK):
   Si durante el proceso de migración ocurre cualquier error de violación 
   de restricciones, tipos de datos incompatibles o falla lógica, la instrucción 
   ROLLBACK deshará por completo todas las inserciones realizadas en este bloque, 
   dejando el esquema BCNF intacto y limpio.

   ORDEN LÓGICO DE INSERCIÓN PARA RESPETAR FOREIGN KEYS:
   1. `categorias`: Independiente.
   2. `productos`: Depende de `categorias`.
   3. `clientes`: Independiente.
   4. `metodos_pago`: Independiente.
   5. `pedidos`: Depende de `clientes` y `metodos_pago`.
   6. `detalle_pedidos`: Depende de `pedidos` y `productos`.
*/

BEGIN;

-- Paso 1: Migrar Categorías unicas (Evitando duplicados con ON CONFLICT)
INSERT INTO categorias (nombre, descripcion)
SELECT DISTINCT categoria_nombre, categoria_descripcion
FROM ventas_historicas_planas
ON CONFLICT (nombre) DO NOTHING;

-- Paso 2: Migrar Productos únicos (Evitando duplicados por nombre y asociando su respectiva categoría)
INSERT INTO productos (categoria_id, nombre, descripcion, precio, stock, disponible, activo)
SELECT DISTINCT 
    c.categoria_id,
    v.producto_nombre,
    v.producto_descripcion,
    v.precio_unitario,
    50, -- Stock inicial por defecto para productos migrados
    TRUE,
    TRUE
FROM ventas_historicas_planas v
JOIN categorias c ON v.categoria_nombre = c.nombre
ON CONFLICT DO NOTHING; -- Nota: Si se requiere upsert estricto, se puede ajustar con UNIQUE en productos(nombre)

-- Paso 3: Migrar Clientes únicos (Basado en email único)
INSERT INTO clientes (nombre, apellido, email, telefono, direccion, fecha_registro, activo)
SELECT DISTINCT 
    cliente_nombre, 
    cliente_apellido, 
    cliente_email, 
    cliente_telefono, 
    cliente_direccion, 
    MIN(fecha_pedido), -- Toma la fecha de su primera compra histórica como registro
    TRUE
FROM ventas_historicas_planas
GROUP BY cliente_nombre, cliente_apellido, cliente_email, cliente_telefono, cliente_direccion
ON CONFLICT (email) DO NOTHING;

-- Paso 4: Migrar Métodos de Pago únicos
INSERT INTO metodos_pago (nombre, activo)
SELECT DISTINCT metodo_pago, TRUE
FROM ventas_historicas_planas
ON CONFLICT (nombre) DO NOTHING;

-- Paso 5: Migrar Cabeceras de Pedidos
-- Agrupamos por datos del pedido para calcular el total consolidado por orden histórica
INSERT INTO pedidos (cliente_id, metodopago_id, fecha_pedido, estado, total)
SELECT 
    cl.cliente_id,
    mp.metodopago_id,
    v.fecha_pedido,
    v.estado_pedido::estado_pedido_enum,
    SUM(v.subtotal) AS total_pedido
FROM ventas_historicas_planas v
JOIN clientes cl ON v.cliente_email = cl.email
JOIN metodos_pago mp ON v.metodo_pago = mp.nombre
GROUP BY cl.cliente_id, mp.metodopago_id, v.fecha_pedido, v.estado_pedido;

-- Paso 6: Migrar Detalle de Pedidos
-- Relaciona cada línea plana con el pedido recién creado y el producto correspondiente
INSERT INTO detalle_pedidos (pedido_id, producto_id, cantidad, precio_unitario)
SELECT 
    p.pedido_id,
    pr.producto_id,
    v.cantidad,
    v.precio_unitario
FROM ventas_historicas_planas v
JOIN clientes cl ON v.cliente_email = cl.email
JOIN metodos_pago mp ON v.metodo_pago = mp.nombre
JOIN pedidos p ON p.cliente_id = cl.cliente_id AND p.fecha_pedido = v.fecha_pedido
JOIN productos pr ON v.producto_nombre = pr.nombre;

-- Si todo se ejecuta sin errores, confirmamos la transacción:
COMMIT;

-- Plan de reversión en caso de emergencia (ejecutar manualmente si falla la transacción):
-- ROLLBACK;