-- =====================================================================
-- SCRIPT DE TAREAS RUTINARIAS Y MANTENIMIENTO ('Food Store')
-- Motor: PostgreSQL 16+
-- =====================================================================

-- 1. Limpieza de tuplas muertas y actualización de estadísticas
-- VACUUM ANALYZE recupera espacio físico de registros eliminados/actualizados 
-- y recalcula las estadísticas para que el optimizador de consultas (Planner) elija los mejores planes.
VACUUM ANALYZE clientes;
VACUUM ANALYZE productos;
VACUUM ANALYZE pedidos;
VACUUM ANALYZE detalle_pedidos;

-- 2. Reconstrucción de índices para evitar la fragmentación
-- REINDEX reconstruye los B-Trees de forma segura y concurrente (CONCURRENTLY 
-- evita bloquear las tablas para lectura/escritura durante el proceso).
REINDEX INDEX CONCURRENTLY idx_productos_categoria;
REINDEX INDEX CONCURRENTLY idx_pedidos_cliente;
REINDEX INDEX CONCURRENTLY idx_pedidos_estado;
REINDEX INDEX CONCURRENTLY idx_detalle_pedidos_pedido;

-- 3. Verificación de Integridad de Datos (Auditoría de consistencia lógica)
-- Consulta A: Buscar pedidos huérfanos (pedidos cuyo cliente_id o metodopago_id no existan en las tablas principales).
-- (Nota: Las FK con restricciones estrictas evitan esto, pero es vital ejecutarlo como control periódico).
SELECT p.pedido_id, p.cliente_id, p.metodopago_id
FROM pedidos p
LEFT JOIN clientes c ON p.cliente_id = c.cliente_id
LEFT JOIN metodos_pago mp ON p.metodopago_id = mp.metodopago_id
WHERE c.cliente_id IS NULL OR mp.metodopago_id IS NULL;

-- Consulta B: Buscar anomalías financieras (pedidos con totales negativos o detalles con cantidades/precios negativos).
SELECT 'pedido_con_total_negativo' AS tipo_anomalia, pedido_id AS id_afectado FROM pedidos WHERE total < 0
UNION ALL
SELECT 'detalle_con_cantidad_invalida', detalle_id FROM detalle_pedidos WHERE cantidad <= 0
UNION ALL
SELECT 'detalle_con_precio_invalido', detalle_id FROM detalle_pedidos WHERE precio_unitario <= 0;
