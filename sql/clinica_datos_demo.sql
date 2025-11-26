DROP PROCEDURE IF EXISTS sp_generar_datos_demo_grande;

DELIMITER //

CREATE PROCEDURE sp_generar_datos_demo_grande()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE max_clientes INT DEFAULT 1000;
    DECLARE max_empleados INT DEFAULT 10;
    DECLARE max_tratamientos INT DEFAULT 12;

    DECLARE cita_id_local INT;
    DECLARE cli_id INT;
    DECLARE emp_id INT;
    DECLARE trat_id INT;
    DECLARE sala_id_local INT;

    -- CATEGORÍAS EMPLEADOS
    INSERT INTO CategoriasEmpleados(nombre, descripcion)
    VALUES
    ('Médico estético','Realiza tratamientos médicos'),
    ('Esteticista','Tratamientos faciales y corporales'),
    ('Recepcionista','Gestión de citas y administración')
    ON DUPLICATE KEY UPDATE nombre = VALUES(nombre);

    -- ESPECIALIDADES
    INSERT INTO Especialidades(nombre, descripcion)
    VALUES
    ('Medicina estética facial','Botox, ácido hialurónico'),
    ('Láser','Depilación láser, manchas'),
    ('Corporal','Celulitis, remodelación')
    ON DUPLICATE KEY UPDATE nombre = VALUES(nombre);

    -- SALAS
    INSERT INTO Salas(nombre,tipo,capacidad)
    VALUES
    ('Cabina 1','Tratamiento',1),
    ('Cabina 2','Tratamiento',1),
    ('Láser 1','Láser',1),
    ('Consulta 1','Consulta',1),
    ('Consulta 2','Consulta',1)
    ON DUPLICATE KEY UPDATE nombre = VALUES(nombre);

    -- CATEGORÍAS TRATAMIENTOS
    INSERT INTO CategoriasTratamientos(nombre, descripcion)
    VALUES
    ('Facial','Tratamientos para rostro'),
    ('Corporal','Tratamientos corporales'),
    ('Láser','Tratamientos con láser')
    ON DUPLICATE KEY UPDATE nombre = VALUES(nombre);

    -- TRATAMIENTOS
    INSERT INTO Tratamientos(nombre, descripcion, precio, duracion_min, categoria_id)
    VALUES
    ('Limpieza facial profunda','Limpieza con extracción', 60.00, 60, 1),
    ('Peeling químico','Renovación de la piel', 90.00, 45, 1),
    ('Botox frontal','Infiltración toxina botulínica', 180.00, 30, 1),
    ('Ácido hialurónico labios','Relleno labial', 220.00, 45, 1),
    ('Masaje reductor','Masaje anticelulítico', 70.00, 60, 2),
    ('Radiofrecuencia corporal','Tensado de la piel', 120.00, 60, 2),
    ('Depilación láser piernas','Láser diodo', 150.00, 45, 3),
    ('Depilación láser axilas','Láser diodo', 80.00, 30, 3),
    ('Depilación láser ingles','Láser diodo', 90.00, 30, 3),
    ('Rejuvenecimiento facial láser','Láser fraccionado', 250.00, 60, 3),
    ('Plasma rico en plaquetas','PRP facial', 200.00, 60, 1),
    ('Tratamiento anticelulítico combinado','Protocolos combinados', 180.00, 75, 2)
    ON DUPLICATE KEY UPDATE nombre = VALUES(nombre);


    -- EMPLEADOS
    SET i = 1;
    WHILE i <= max_empleados DO
        INSERT INTO Empleados(nombre, apellido, fecha_ingreso, telefono, email, categoria_id, activo)
        VALUES (
            CONCAT('Empleado', i),
            CONCAT('Apellido', i),
            DATE_SUB(CURDATE(), INTERVAL (30 + i) DAY),
            CONCAT('+34 600000', LPAD(i,3,'0')),
            CONCAT('empleado', i, '@clinica.com'),
            CASE
                WHEN i <= 3 THEN 1
                WHEN i <= 6 THEN 2
                ELSE 3
            END,
            TRUE
        );
        SET i = i + 1;
    END WHILE;


    -- CLIENTES
    SET i = 1;
    WHILE i <= max_clientes DO
        INSERT INTO Clientes(dni, nombre, apellido, fecha_nacimiento, edad, genero, telefono, correo, direccion, fecha_registro, origen_cliente)
        VALUES (
            CONCAT('0000', LPAD(i,4,'0'), 'X'),
            CONCAT('Cliente', i),
            CONCAT('Apellido', i),
            DATE_SUB(CURDATE(), INTERVAL (20 + FLOOR(RAND()*40)) YEAR),
            NULL,
            ELT(FLOOR(1 + RAND()*3),'Hombre','Mujer','Otro'),
            CONCAT('+34 600', LPAD(i,6,'0')),
            CONCAT('cliente', i, '@correo.com'),
            CONCAT('C/ Falsa ', i, ', Ciudad'),
            NULL,
            ELT(FLOOR(1 + RAND()*5),'Google','Instagram','Recomendacion','Web','Publicidad')
        );
        SET i = i + 1;
    END WHILE;


END//

DELIMITER ;

CALL sp_generar_datos_demo_grande();
