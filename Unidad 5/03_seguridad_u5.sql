-- =====================================================================
-- SCRIPT COMPLETO DE ADMINISTRACIÓN, SEGURIDAD Y AUDITORÍA ('Food Store')
-- Motor: PostgreSQL 16+
-- =====================================================================

-- =====================================================================
-- PASO 1: Creación de Roles y Usuarios con el Principio de Mínimo Privilegio
-- =====================================================================

-- 1.1 Creación de Roles (Agrupadores de permisos)
CREATE ROLE rol_admin;
CREATE ROLE rol_app_backend;
CREATE ROLE rol_auditor;

-- 1.2 Creación de Usuarios con contraseñas seguras
CREATE USER usr_admin WITH PASSWORD 'AdminSecurePassword2026!';
CREATE USER usr_backend WITH PASSWORD 'BackendAppPass2026!';
CREATE USER usr_auditor WITH PASSWORD 'AuditorSecurePass2026!';

-- Asignación de los roles a sus respectivos usuarios
GRANT rol_admin TO usr_admin;
GRANT rol_app_backend TO usr_backend;
GRANT rol_auditor TO usr_auditor;

-- 1.3 Revocación previa de permisos globales por defecto en el esquema público
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;

-- 1.4 Asignación de Privilegios específicos (Principio de Mínimo Privilegio)

-- ROL ADMIN: Acceso total de gestión sobre el esquema e infraestructura de datos
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO rol_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO rol_admin;

-- ROL APP BACKEND: Aplicación operativa (SELECT, INSERT, UPDATE para operaciones, sin DROP ni DELETE físico)
GRANT SELECT, INSERT, UPDATE ON clientes, categorias, productos, metodos_pago, pedidos, detalle_pedidos TO rol_app_backend;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO rol_app_backend;
-- Nota explícita: Se omite por completo DELETE para prohibir borrados físicos.

-- ROL AUDITOR: Solo lectura analítica y de control sobre tablas e historial de auditoría
GRANT SELECT ON ALL TABLES IN SCHEMA public TO rol_auditor;


-- =====================================================================
-- PASO 2: Sistema de Auditoría Automática (Tabla y Trigger PL/pgSQL)
-- =====================================================================

-- 2.1 Creación de la tabla de auditoría
CREATE TABLE auditoria_operaciones (
    auditoria_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    usuario VARCHAR(100) NOT NULL,
    tabla_afectada VARCHAR(100) NOT NULL,
    operacion VARCHAR(20) NOT NULL, -- UPDATE o DELETE
    fecha TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    datos_previos JSONB -- Almacena el estado previo de la fila para trazabilidad forense
);

-- 2.2 Función PL/pgSQL disparadora de auditoría
CREATE OR REPLACE FUNCTION fn_registrar_auditoria()
RETURNS TRIGGER
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

-- 2.3 Aplicación de Triggers de auditoría sobre 'clientes' y 'pedidos'
CREATE TRIGGER trg_auditar_clientes
AFTER UPDATE OR DELETE ON clientes
FOR EACH ROW
EXECUTE FUNCTION fn_registrar_auditoria();

CREATE TRIGGER trg_auditar_pedidos
AFTER UPDATE OR DELETE ON pedidos
FOR EACH ROW
EXECUTE FUNCTION fn_registrar_auditoria();