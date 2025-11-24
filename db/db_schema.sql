-- Base de datos clínica
CREATE DATABASE IF NOT EXISTS clinica_db;
USE clinica_db;

-- ============================================
-- TABLA: Clientes / Pacientes
-- ============================================
CREATE TABLE clientes (
    cliente_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    edad INT,
    genero VARCHAR(10),
    telefono VARCHAR(20),
    correo VARCHAR(100),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLA: Categorías de Empleados
-- ============================================
CREATE TABLE categorias_empleados (
    categoria_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255)
);

-- ============================================
-- TABLA: Empleados
-- ============================================
CREATE TABLE empleados (
    empleado_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    fecha_ingreso DATE,
    telefono VARCHAR(20),
    categoria_id INT,
    FOREIGN KEY (categoria_id) REFERENCES categorias_empleados(categoria_id)
);

-- ============================================
-- TABLA: Categorías de Tratamientos
-- ============================================
CREATE TABLE categorias_tratamientos (
    categoria_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255)
);

-- ============================================
-- TABLA: Tratamientos
-- ============================================
CREATE TABLE tratamientos (
    tratamiento_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255),
    precio DECIMAL(10,2),
    duracion_min INT,
    categoria_id INT,
    FOREIGN KEY (categoria_id) REFERENCES categorias_tratamientos(categoria_id)
);

-- ============================================
-- TABLA: Fichas Médicas
-- ============================================
CREATE TABLE fichas_medicas (
    ficha_id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT,
    alergias TEXT,
    observaciones TEXT,
    FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id)
);

-- ============================================
-- TABLA: Citas
-- ============================================
CREATE TABLE citas (
    cita_id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT,
    empleado_id INT,
    tratamiento_id INT,
    fecha_cita DATE,
    hora_cita TIME,
    estado ENUM('pendiente','realizada','cancelada') DEFAULT 'pendiente',
    observaciones TEXT,
    FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id),
    FOREIGN KEY (empleado_id) REFERENCES empleados(empleado_id),
    FOREIGN KEY (tratamiento_id) REFERENCES tratamientos(tratamiento_id)
);

-- ============================================
-- TABLA: Pagos
-- ============================================
CREATE TABLE pagos (
    pago_id INT AUTO_INCREMENT PRIMARY KEY,
    cita_id INT,
    metodo_pago ENUM('efectivo','tarjeta','transferencia'),
    monto DECIMAL(10,2),
    fecha_pago TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cita_id) REFERENCES citas(cita_id)
);

-- ============================================
-- TABLA: Valoraciones
-- ============================================
CREATE TABLE valoraciones (
    valoracion_id INT AUTO_INCREMENT PRIMARY KEY,
    cita_id INT,
    puntuacion INT CHECK(puntuacion BETWEEN 1 AND 5),
    comentario TEXT,
    fecha_valoracion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cita_id) REFERENCES citas(cita_id)
);

-- ============================================
-- TABLA: Tratamientos Previos (historial del cliente)
-- ============================================
CREATE TABLE tratamientos_previos (
    cliente_id INT,
    tratamiento_id INT,
    fecha_tratamiento DATE,
    PRIMARY KEY(cliente_id, tratamiento_id, fecha_tratamiento),
    FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id),
    FOREIGN KEY (tratamiento_id) REFERENCES tratamientos(tratamiento_id)
);

-- ============================================
-- TABLA: Proveedores
-- ============================================
CREATE TABLE proveedores (
    proveedor_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    correo VARCHAR(100),
    direccion VARCHAR(255)
);

-- ============================================
-- TABLA: Inventario (productos/materiales)
-- ============================================
CREATE TABLE inventario (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo ENUM('insumo','producto'),
    stock_actual INT,
    unidad VARCHAR(20),
    costo_unitario DECIMAL(10,2),
    proveedor_id INT,
    FOREIGN KEY (proveedor_id) REFERENCES proveedores(proveedor_id)
);

-- ============================================
-- TABLA: Consumo de Material en Citas
-- ============================================
CREATE TABLE consumo_material (
    cita_id INT,
    item_id INT,
    cantidad_usada DECIMAL(10,2),
    PRIMARY KEY(cita_id, item_id),
    FOREIGN KEY (cita_id) REFERENCES citas(cita_id),
    FOREIGN KEY (item_id) REFERENCES inventario(item_id)
);
