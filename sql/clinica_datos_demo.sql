USE clinica_db;

DELIMITER $$

CREATE PROCEDURE sp_generar_datos_demo_grande()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE max_clientes INT DEFAULT 1000;
    DECLARE max_empleados INT DEFAULT 10;
    DECLARE max_tratamientos INT DEFAULT 12;
    DECLARE max_items INT DEFAULT 15;
    DECLARE cita_id_local INT;
    DECLARE cli_id INT;
    DECLARE emp_id INT;
    DECLARE trat_id INT;
    DECLARE sala_id_local INT;

    -- Categorías empleados
    INSERT INTO CategoriasEmpleados(nombre, descripcion) VALUES
    ('Médico estético','Realiza tratamientos médicos'),
    ('Esteticista','Tratamientos faciales y corporales'),
    ('Recepcionista','Gestión de citas y administración')
    ON DUPLICATE KEY UPDATE nombre = VALUES(nombre);

    -- Especialidades
    INSERT INTO Especialidades(nombre, descripcion) VALUES
    ('Medicina estética facial','Botox, ácido hialurónico'),
    ('Láser','Depilación láser, manchas'),
    ('Corporal','Celulitis, remodelación')
    ON DUPLICATE KEY UPDATE nombre = VALUES(nombre);

    -- Salas
    INSERT INTO Salas(nombre,tipo,capacidad) VALUES
    ('Cabina 1','Tratamiento',1),
    ('Cabina 2','Tratamiento',1),
    ('Láser 1','Láser',1),
    ('Consulta 1','Consulta',1),
    ('Consulta 2','Consulta',1)
    ON DUPLICATE KEY UPDATE nombre = VALUES(nombre);

    -- Categorías tratamientos
    INSERT INTO CategoriasTratamientos(nombre, descripcion) VALUES
    ('Facial','Tratamientos para rostro'),
    ('Corporal','Tratamientos corporales'),
    ('Láser','Tratamientos con láser')
    ON DUPLICATE KEY UPDATE nombre = VALUES(nombre);

    -- Tratamientos
    INSERT INTO Tratamientos(nombre, descripcion, precio, duracion_min, categoria_id) VALUES
    ('Limpieza facial profunda','Limpieza con extracción', 60.00, 60, 1),
    ('Peeling químico','Renovación de la piel', 90.00, 45, 1),
    ('Botox frontal','Infiltración toxina botulínica', 180.00, 30, 1),
    ('Ácido hialurónico labios','Relleno labial', 220.00, 45, 1),
    ('Masaje reductor','Masaje corporal anticelulítico', 70.00, 60, 2),
    ('Radiofrecuencia corporal','Tensado de la piel', 120.00, 60, 2),
    ('Depilación láser piernas','Láser diodo', 150.00, 45, 3),
    ('Depilación láser axilas','Láser diodo', 80.00, 30, 3),
    ('Depilación láser ingles','Láser diodo', 90.00, 30, 3),
    ('Rejuvenecimiento facial láser','Láser fraccionado', 250.00, 60, 3),
    ('Plasma rico en plaquetas','PRP facial', 200.00, 60, 1),
    ('Tratamiento anticelulítico combinado','Varios protocolos', 180.00, 75, 2)
    ON DUPLICATE KEY UPDATE nombre = VALUES(nombre);

    -- Empleados
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

    -- EmpleadoEspecialidad (solo para médicos)
    INSERT INTO EmpleadoEspecialidad(empleado_id, especialidad_id)
    SELECT empleado_id, 1 FROM Empleados WHERE categoria_id = 1
    ON DUPLICATE KEY UPDATE especialidad_id = VALUES(especialidad_id);

    -- Proveedores
    INSERT INTO Proveedores(nombre, telefono, correo, direccion) VALUES
    ('Proveedor Estética 1','+34 910000001','contacto1@proveedor.com','C/ Proveedor 1, Madrid'),
    ('Proveedor Estética 2','+34 910000002','contacto2@proveedor.com','C/ Proveedor 2, Madrid')
    ON DUPLICATE KEY UPDATE nombre = VALUES(nombre);

    -- Inventario básico
    INSERT INTO Inventario(nombre,tipo,stock_actual,unidad,costo_unitario,proveedor_id) VALUES
    ('Crema hidratante post-tratamiento','producto',200,'uds',8.00,1),
    ('Ácido hialurónico vial','insumo',120,'uds',45.00,1),
    ('Jeringas estériles','insumo',500,'uds',0.50,2),
    ('Guantes nitrilo','insumo',1000,'uds',0.10,2),
    ('Mascarilla facial tratamiento','producto',300,'uds',3.50,1),
    ('Gel conductor láser','insumo',80,'botes',15.00,1),
    ('Toxina botulínica vial','insumo',60,'uds',95.00,1),
    ('Gasas estériles','insumo',800,'uds',0.05,2),
    ('Alcohol 70%','insumo',100,'botes',4.00,2),
    ('Serum regenerador','producto',150,'uds',12.00,1),
    ('Crema anticelulítica','producto',180,'uds',16.00,1),
    ('Ampollas PRP kit','insumo',90,'uds',30.00,2),
    ('Cinta de sujeción','equipamiento',30,'uds',10.00,2),
    ('Sábana desechable camilla','insumo',400,'uds',0.40,2),
    ('Mascarilla peel-off','producto',200,'uds',5.00,1)
    ON DUPLICATE KEY UPDATE nombre = VALUES(nombre);

    -- Campañas marketing
    INSERT INTO CampañasMarketing(nombre, canal, fecha_inicio, fecha_fin, presupuesto) VALUES
    ('Promo verano láser','Instagram', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_SUB(CURDATE(), INTERVAL 60 DAY), 1500.00),
    ('Campaña facial otoño','Google Ads', DATE_SUB(CURDATE(), INTERVAL 60 DAY), DATE_SUB(CURDATE(), INTERVAL 30 DAY), 1200.00),
    ('Colaboración influencer belleza','Colaboración', DATE_SUB(CURDATE(), INTERVAL 30 DAY), CURDATE(), 2000.00)
    ON DUPLICATE KEY UPDATE nombre = VALUES(nombre);

    -- Promociones
    INSERT INTO DescuentosPromociones(nombre, tipo, valor, fecha_inicio, fecha_fin) VALUES
    ('-20% Láser verano','porcentaje',20.00, DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_SUB(CURDATE(), INTERVAL 60 DAY)),
    ('Peeling 2x1','porcentaje',50.00, DATE_SUB(CURDATE(), INTERVAL 45 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY)),
    ('Bono 3 masajes','cantidad_fija',30.00, DATE_SUB(CURDATE(), INTERVAL 20 DAY), DATE_ADD(CURDATE(), INTERVAL 10 DAY))
    ON DUPLICATE KEY UPDATE nombre = VALUES(nombre);

    -- Clientes
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
            DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND()*365) DAY),
            ELT(FLOOR(1 + RAND()*5),'Google','Instagram','Recomendacion','Web','Publicidad')
        );
        SET i = i + 1;
    END WHILE;

    -- Actualizar edad con la función
    UPDATE Clientes
    SET edad = fn_calcular_edad(fecha_nacimiento);

    -- Citas + Pagos + Valoraciones + ConsumoMaterial
    SET i = 1;
    WHILE i <= (max_clientes * 7) DO  -- ~7 citas de media por cliente
        SET cli_id = 1 + FLOOR(RAND() * max_clientes);
        SET emp_id = 1 + FLOOR(RAND() * max_empleados);
        SET trat_id = 1 + FLOOR(RAND() * max_tratamientos);
        SET sala_id_local = 1 + FLOOR(RAND() * 5);

        INSERT INTO Citas(cliente_id, empleado_id, tratamiento_id, sala_id, fecha_cita, hora_cita, estado, observaciones)
        VALUES (
            cli_id,
            emp_id,
            trat_id,
            sala_id_local,
            DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND()*365) DAY),
            MAKETIME(9 + FLOOR(RAND()*9), IF(FLOOR(RAND()*2)=0,0,30),0),
            ELT(FLOOR(1 + RAND()*5),'pendiente','confirmada','realizada','cancelada','reprogramada'),
            'Cita generada de prueba'
        );

        SET cita_id_local = LAST_INSERT_ID();

        -- Si la cita está realizada, generar pago y posible valoración
        IF (SELECT estado FROM Citas WHERE cita_id = cita_id_local) = 'realizada' THEN
            INSERT INTO Pagos(cita_id, metodo_pago, monto, fecha_pago)
            SELECT
                cita_id_local,
                ELT(FLOOR(1 + RAND()*4),'efectivo','tarjeta','transferencia','bizum'),
                precio,
                CONCAT(fecha_cita, ' ', hora_cita)
            FROM Citas c
            JOIN Tratamientos t ON t.tratamiento_id = c.tratamiento_id
            WHERE c.cita_id = cita_id_local;

            IF RAND() > 0.3 THEN
                INSERT INTO Valoraciones(cita_id, puntuacion, comentario)
                VALUES (
                    cita_id_local,
                    3 + FLOOR(RAND()*3),
                    'Valoración automática de prueba'
                );
            END IF;

            -- Consumo material básico ligado al tratamiento_id (simplificado)
            INSERT INTO ConsumoMaterial(cita_id, item_id, cantidad_usada)
            VALUES
                (cita_id_local, 3, 1), -- jeringas
                (cita_id_local, 4, 2); -- guantes
        END IF;

        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;

CALL sp_generar_datos_demo_grande();
