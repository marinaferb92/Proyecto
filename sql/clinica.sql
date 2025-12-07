DROP DATABASE IF EXISTS clinica_db;
CREATE DATABASE clinica_db;
USE clinica_db;

SET FOREIGN_KEY_CHECKS = 0;

-- Drops (igual que tenías)
DROP VIEW IF EXISTS vw_ingresos_mensuales;
DROP VIEW IF EXISTS vw_tratamientos_mas_demandados;
DROP VIEW IF EXISTS vw_stock_critico;
DROP VIEW IF EXISTS vw_productividad_empleados;

DROP EVENT IF EXISTS ev_calculo_diario_estadisticas;
DROP EVENT IF EXISTS ev_limpiar_logs;

DROP TRIGGER IF EXISTS trg_crear_ficha_medica;
DROP TRIGGER IF EXISTS trg_actualizar_estado_cita;
DROP TRIGGER IF EXISTS trg_insertar_tratamiento_prev;
DROP TRIGGER IF EXISTS trg_descontar_stock;
DROP TRIGGER IF EXISTS trg_movimiento_inventario;
DROP TRIGGER IF EXISTS trg_log_actividad_cita;

DROP PROCEDURE IF EXISTS sp_calcular_estadisticas_dia;
DROP PROCEDURE IF EXISTS sp_generar_datos_demo_grande;

DROP FUNCTION IF EXISTS fn_calcular_edad;

DROP TABLE IF EXISTS CitaPromocion;
DROP TABLE IF EXISTS DescuentosPromociones;
DROP TABLE IF EXISTS CampañasMarketing;
DROP TABLE IF EXISTS MovimientosInventario;
DROP TABLE IF EXISTS ConsumoMaterial;
DROP TABLE IF EXISTS Inventario;
DROP TABLE IF EXISTS Proveedores;
DROP TABLE IF EXISTS Valoraciones;
DROP TABLE IF EXISTS Pagos;
DROP TABLE IF EXISTS Citas;
DROP TABLE IF EXISTS TratamientosPrevios;
DROP TABLE IF EXISTS Tratamientos;
DROP TABLE IF EXISTS CategoriasTratamientos;
DROP TABLE IF EXISTS Salas;
DROP TABLE IF EXISTS FichasMedicas;
DROP TABLE IF EXISTS LogsActividad;
DROP TABLE IF EXISTS EmpleadoEspecialidad;
DROP TABLE IF EXISTS Especialidades;
DROP TABLE IF EXISTS Empleados;
DROP TABLE IF EXISTS CategoriasEmpleados;
DROP TABLE IF EXISTS Clientes;
DROP TABLE IF EXISTS EstadisticasDiarias;

SET FOREIGN_KEY_CHECKS = 1;

-- CLIENTES
CREATE TABLE Clientes (
    cliente_id INT AUTO_INCREMENT PRIMARY KEY,
    dni VARCHAR(15) UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE,
    edad INT,
    genero ENUM('Hombre','Mujer','Otro') DEFAULT 'Mujer',
    telefono VARCHAR(20),
    correo VARCHAR(100),
    direccion TEXT,
    fecha_registro DATE,
    origen_cliente ENUM('Google','Instagram','Recomendacion','Web','Publicidad','Otro') DEFAULT 'Recomendacion'
) ENGINE=InnoDB;

-- CATEGORÍAS EMPLEADOS
CREATE TABLE CategoriasEmpleados (
    categoria_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT
) ENGINE=InnoDB;

-- EMPLEADOS
CREATE TABLE Empleados (
    empleado_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    fecha_ingreso DATE,
    telefono VARCHAR(20),
    email VARCHAR(100),
    categoria_id INT,
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (categoria_id) REFERENCES CategoriasEmpleados(categoria_id)
        ON DELETE SET NULL
) ENGINE=InnoDB;

-- ESPECIALIDADES
CREATE TABLE Especialidades (
    especialidad_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT
) ENGINE=InnoDB;

CREATE TABLE EmpleadoEspecialidad (
    empleado_id INT,
    especialidad_id INT,
    PRIMARY KEY (empleado_id, especialidad_id),
    FOREIGN KEY (empleado_id) REFERENCES Empleados(empleado_id)
        ON DELETE CASCADE,
    FOREIGN KEY (especialidad_id) REFERENCES Especialidades(especialidad_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- FICHAS MÉDICAS
CREATE TABLE FichasMedicas (
    ficha_id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    alergias TEXT,
    antecedentes TEXT,
    observaciones TEXT,
    fecha_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES Clientes(cliente_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- SALAS
CREATE TABLE Salas (
    sala_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo ENUM('Tratamiento','Consulta','Láser','Cabina','Quirófano') DEFAULT 'Tratamiento',
    capacidad INT DEFAULT 1
) ENGINE=InnoDB;

-- CATEGORÍAS TRATAMIENTOS
CREATE TABLE CategoriasTratamientos (
    categoria_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT
) ENGINE=InnoDB;

-- TRATAMIENTOS
CREATE TABLE Tratamientos (
    tratamiento_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    duracion_min INT NOT NULL,
    categoria_id INT,
    requiere_sala BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (categoria_id) REFERENCES CategoriasTratamientos(categoria_id)
        ON DELETE SET NULL
) ENGINE=InnoDB;

-- TRATAMIENTOS PREVIOS
CREATE TABLE TratamientosPrevios (
    cliente_id INT,
    tratamiento_id INT,
    fecha_tratamiento DATE,
    notas TEXT,
    PRIMARY KEY (cliente_id, tratamiento_id, fecha_tratamiento),
    FOREIGN KEY (cliente_id) REFERENCES Clientes(cliente_id)
        ON DELETE CASCADE,
    FOREIGN KEY (tratamiento_id) REFERENCES Tratamientos(tratamiento_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- CITAS
CREATE TABLE Citas (
    cita_id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    empleado_id INT NOT NULL,
    tratamiento_id INT NOT NULL,
    sala_id INT,
    fecha_cita DATE NOT NULL,
    hora_cita TIME NOT NULL,
    estado ENUM('pendiente','confirmada','realizada','cancelada','reprogramada')
        DEFAULT 'pendiente',
    observaciones TEXT,
    FOREIGN KEY (cliente_id) REFERENCES Clientes(cliente_id)
        ON DELETE CASCADE,
    FOREIGN KEY (empleado_id) REFERENCES Empleados(empleado_id)
        ON DELETE CASCADE,
    FOREIGN KEY (tratamiento_id) REFERENCES Tratamientos(tratamiento_id)
        ON DELETE CASCADE,
    FOREIGN KEY (sala_id) REFERENCES Salas(sala_id)
        ON DELETE SET NULL
) ENGINE=InnoDB;

-- PAGOS
CREATE TABLE Pagos (
    pago_id INT AUTO_INCREMENT PRIMARY KEY,
    cita_id INT NOT NULL,
    metodo_pago ENUM('efectivo','tarjeta','transferencia','bizum','otro') DEFAULT 'tarjeta',
    monto DECIMAL(10,2) NOT NULL,
    fecha_pago DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cita_id) REFERENCES Citas(cita_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- VALORACIONES
CREATE TABLE Valoraciones (
    valoracion_id INT AUTO_INCREMENT PRIMARY KEY,
    cita_id INT NOT NULL,
    puntuacion INT CHECK (puntuacion BETWEEN 1 AND 5),
    comentario TEXT,
    fecha_valoracion DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cita_id) REFERENCES Citas(cita_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- PROVEEDORES
CREATE TABLE Proveedores (
    proveedor_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    correo VARCHAR(100),
    direccion TEXT
) ENGINE=InnoDB;

-- INVENTARIO
CREATE TABLE Inventario (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo ENUM('insumo','producto','equipamiento') DEFAULT 'insumo',
    stock_actual INT NOT NULL DEFAULT 0,
    unidad VARCHAR(20),
    costo_unitario DECIMAL(10,2),
    proveedor_id INT,
    FOREIGN KEY (proveedor_id) REFERENCES Proveedores(proveedor_id)
        ON DELETE SET NULL
) ENGINE=InnoDB;

-- CONSUMO MATERIAL
CREATE TABLE ConsumoMaterial (
    cita_id INT,
    item_id INT,
    cantidad_usada INT NOT NULL,
    PRIMARY KEY (cita_id, item_id),
    FOREIGN KEY (cita_id) REFERENCES Citas(cita_id)
        ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES Inventario(item_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- MOVIMIENTOS INVENTARIO
CREATE TABLE MovimientosInventario (
    movimiento_id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL,
    tipo ENUM('entrada','salida','ajuste') NOT NULL,
    cantidad INT NOT NULL,
    fecha_movimiento DATETIME DEFAULT CURRENT_TIMESTAMP,
    descripcion TEXT,
    FOREIGN KEY (item_id) REFERENCES Inventario(item_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- CAMPAÑAS MARKETING
CREATE TABLE CampañasMarketing (
    campaña_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    canal ENUM('Instagram','Facebook','Google Ads','Cartelería','Colaboración','Otro') DEFAULT 'Instagram',
    fecha_inicio DATE,
    fecha_fin DATE,
    presupuesto DECIMAL(10,2)
) ENGINE=InnoDB;

-- PROMOCIONES
CREATE TABLE DescuentosPromociones (
    promo_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo ENUM('porcentaje','cantidad_fija') NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    fecha_inicio DATE,
    fecha_fin DATE
) ENGINE=InnoDB;

CREATE TABLE CitaPromocion (
    cita_id INT,
    promo_id INT,
    PRIMARY KEY (cita_id, promo_id),
    FOREIGN KEY (cita_id) REFERENCES Citas(cita_id)
        ON DELETE CASCADE,
    FOREIGN KEY (promo_id) REFERENCES DescuentosPromociones(promo_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- LOGS
CREATE TABLE LogsActividad (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    empleado_id INT,
    accion VARCHAR(255),
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (empleado_id) REFERENCES Empleados(empleado_id)
        ON DELETE SET NULL
) ENGINE=InnoDB;

-- ESTADÍSTICAS DIARIAS
CREATE TABLE EstadisticasDiarias (
    fecha DATE PRIMARY KEY,
    citas_totales INT,
    citas_realizadas INT,
    citas_canceladas INT,
    ingresos_totales DECIMAL(10,2),
    tratamientos_distintos INT
) ENGINE=InnoDB;

SET FOREIGN_KEY_CHECKS = 1;

-- USUARIOS
CREATE TABLE Usuarios (
    usuario_id INT AUTO_INCREMENT PRIMARY KEY,
    empleado_id INT NULL,
    nombre_usuario VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    rol ENUM('admin','recepcionista','medico') NOT NULL DEFAULT 'recepcionista',
    activo TINYINT(1) DEFAULT 1,
    FOREIGN KEY (empleado_id) REFERENCES Empleados(empleado_id)
        ON DELETE SET NULL
);


-- =============================================
-- ÍNDICES
-- =============================================

CREATE INDEX idx_citas_cliente ON Citas(cliente_id);
CREATE INDEX idx_citas_empleado ON Citas(empleado_id);
CREATE INDEX idx_citas_fecha ON Citas(fecha_cita);

CREATE INDEX idx_pagos_fecha ON Pagos(fecha_pago);
CREATE INDEX idx_mov_inv_fecha ON MovimientosInventario(fecha_movimiento);

CREATE INDEX idx_inventario_tipo ON Inventario(tipo);

CREATE INDEX idx_trat_prev_cli ON TratamientosPrevios(cliente_id);
CREATE INDEX idx_trat_prev_fecha ON TratamientosPrevios(fecha_tratamiento);

-- =============================================
-- FUNCIÓN
-- =============================================

DELIMITER $$

CREATE FUNCTION fn_calcular_edad(fecha_nacimiento DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE edad INT;
    IF fecha_nacimiento IS NULL THEN
        RETURN NULL;
    END IF;
    SET edad = TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE());
    RETURN edad;
END$$

DELIMITER ;

-- =============================================
-- TRIGGERS (con @TRIGGER_DISABLED)
-- =============================================

DELIMITER $$

CREATE TRIGGER trg_crear_ficha_medica
AFTER INSERT ON Clientes
FOR EACH ROW
BEGIN
    IF @TRIGGER_DISABLED IS NULL OR @TRIGGER_DISABLED = FALSE THEN
        INSERT INTO FichasMedicas(cliente_id, alergias, antecedentes, observaciones)
        VALUES (NEW.cliente_id, '', '', '');
    END IF;
END$$

CREATE TRIGGER trg_actualizar_estado_cita
AFTER INSERT ON Pagos
FOR EACH ROW
BEGIN
    IF @TRIGGER_DISABLED IS NULL OR @TRIGGER_DISABLED = FALSE THEN
        UPDATE Citas SET estado = 'realizada'
        WHERE cita_id = NEW.cita_id;
    END IF;
END$$

CREATE TRIGGER trg_insertar_tratamiento_prev
AFTER UPDATE ON Citas
FOR EACH ROW
BEGIN
    IF @TRIGGER_DISABLED IS NULL OR @TRIGGER_DISABLED = FALSE THEN
        IF NEW.estado = 'realizada' AND OLD.estado <> 'realizada' THEN
            INSERT INTO TratamientosPrevios(cliente_id, tratamiento_id, fecha_tratamiento, notas)
            VALUES (NEW.cliente_id, NEW.tratamiento_id, NEW.fecha_cita, NEW.observaciones);
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_descontar_stock
AFTER INSERT ON ConsumoMaterial
FOR EACH ROW
BEGIN
    IF @TRIGGER_DISABLED IS NULL OR @TRIGGER_DISABLED = FALSE THEN
        UPDATE Inventario
        SET stock_actual = stock_actual - NEW.cantidad_usada
        WHERE item_id = NEW.item_id;
    END IF;
END$$

CREATE TRIGGER trg_movimiento_inventario
AFTER INSERT ON MovimientosInventario
FOR EACH ROW
BEGIN
    IF @TRIGGER_DISABLED IS NULL OR @TRIGGER_DISABLED = FALSE THEN
        IF NEW.tipo = 'entrada' THEN
            UPDATE Inventario SET stock_actual = stock_actual + NEW.cantidad
            WHERE item_id = NEW.item_id;
        ELSEIF NEW.tipo = 'salida' THEN
            UPDATE Inventario SET stock_actual = stock_actual - NEW.cantidad
            WHERE item_id = NEW.item_id;
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_log_actividad_cita
AFTER UPDATE ON Citas
FOR EACH ROW
BEGIN
    IF @TRIGGER_DISABLED IS NULL OR @TRIGGER_DISABLED = FALSE THEN
        INSERT INTO LogsActividad(empleado_id, accion)
        VALUES (NEW.empleado_id, CONCAT('Cita ', NEW.cita_id, ' actualizada a ', NEW.estado));
    END IF;
END$$

DELIMITER ;

-- =============================================
-- PROCEDIMIENTO ESTADÍSTICAS
-- =============================================

DELIMITER $$

CREATE PROCEDURE sp_calcular_estadisticas_dia(IN p_fecha DATE)
BEGIN
    INSERT INTO EstadisticasDiarias(fecha, citas_totales, citas_realizadas,
                                    citas_canceladas, ingresos_totales, tratamientos_distintos)
    SELECT
        p_fecha,
        COUNT(c.cita_id),
        SUM(c.estado = 'realizada'),
        SUM(c.estado = 'cancelada'),
        IFNULL((SELECT SUM(p.monto)
                FROM Pagos p
                JOIN Citas c2 ON c2.cita_id = p.cita_id
                WHERE c2.fecha_cita = p_fecha), 0),
        COUNT(DISTINCT c.tratamiento_id)
    FROM Citas c
    WHERE c.fecha_cita = p_fecha
    ON DUPLICATE KEY UPDATE
        citas_totales = VALUES(citas_totales),
        citas_realizadas = VALUES(citas_realizadas),
        citas_canceladas = VALUES(citas_canceladas),
        ingresos_totales = VALUES(ingresos_totales),
        tratamientos_distintos = VALUES(tratamientos_distintos);
END$$

DELIMITER ;

-- =============================================
-- VISTAS
-- =============================================

CREATE OR REPLACE VIEW vw_ingresos_mensuales AS
SELECT
    DATE_FORMAT(p.fecha_pago, '%Y-%m') AS año_mes,
    SUM(p.monto) AS ingresos_totales,
    COUNT(*) AS pagos_totales
FROM Pagos p
GROUP BY DATE_FORMAT(p.fecha_pago, '%Y-%m');

CREATE OR REPLACE VIEW vw_tratamientos_mas_demandados AS
SELECT
    t.tratamiento_id,
    t.nombre,
    COUNT(c.cita_id) AS numero_citas
FROM Tratamientos t
LEFT JOIN Citas c ON c.tratamiento_id = t.tratamiento_id
GROUP BY t.tratamiento_id, t.nombre
ORDER BY numero_citas DESC;

CREATE OR REPLACE VIEW vw_stock_critico AS
SELECT *
FROM Inventario
WHERE stock_actual < 10;

CREATE OR REPLACE VIEW vw_productividad_empleados AS
SELECT 
    e.empleado_id,
    e.nombre,
    e.apellido,
    COUNT(c.cita_id) AS citas_totales,
    SUM(c.estado = 'realizada') AS realizadas
FROM Empleados e
LEFT JOIN Citas c ON c.empleado_id = e.empleado_id
GROUP BY e.empleado_id, e.nombre, e.apellido;

-- =============================================
-- EVENTOS
-- =============================================

SET GLOBAL event_scheduler = ON;

DELIMITER $$

CREATE EVENT IF NOT EXISTS ev_calculo_diario_estadisticas
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP + INTERVAL 1 HOUR
DO
BEGIN
    CALL sp_calcular_estadisticas_dia(CURDATE() - INTERVAL 1 DAY);
END$$

CREATE EVENT IF NOT EXISTS ev_limpiar_logs
ON SCHEDULE EVERY 1 MONTH
DO
BEGIN
    DELETE FROM LogsActividad WHERE fecha < NOW() - INTERVAL 1 YEAR;
END$$

DELIMITER ;