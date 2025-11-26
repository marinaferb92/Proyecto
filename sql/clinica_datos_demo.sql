USE clinica_db;

DELIMITER $$

CREATE PROCEDURE sp_generar_datos_demo_grande()
BEGIN
    -- Desactivar triggers y checks
    SET @OLD_FOREIGN_KEY_CHECKS = @@FOREIGN_KEY_CHECKS;
    SET @OLD_UNIQUE_CHECKS = @@UNIQUE_CHECKS;
    SET FOREIGN_KEY_CHECKS = 0;
    SET UNIQUE_CHECKS = 0;
    SET @TRIGGER_DISABLED = TRUE;

    DECLARE i INT DEFAULT 1;
    DECLARE max_clientes INT DEFAULT 1000;
    DECLARE max_empleados INT;
    DECLARE max_tratamientos INT;
    DECLARE max_salas INT;
    DECLARE cita_id_local INT;
    DECLARE cli_id INT;
    DECLARE emp_id INT;
    DECLARE trat_id INT;
    DECLARE sala_id_local INT;

    -- Calcular conteos reales
    SELECT COUNT(*) INTO max_empleados FROM Empleados;
    SELECT COUNT(*) INTO max_tratamientos FROM Tratamientos;
    SELECT COUNT(*) INTO max_salas FROM Salas;

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

    -- Actualizar edad
    UPDATE Clientes
    SET edad = fn_calcular_edad(fecha_nacimiento);

    -- CITAS + PAGOS + VALORACIONES + CONSUMO
    SET i = 1;
    WHILE i <= (max_clientes * 7) DO
        SET cli_id = 1 + FLOOR(RAND() * max_clientes);
        SET emp_id = 1 + FLOOR(RAND() * max_empleados);
        SET trat_id = 1 + FLOOR(RAND() * max_tratamientos);
        SET sala_id_local = 1 + FLOOR(RAND() * max_salas);

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
                VALUES (cita_id_local, 3 + FLOOR(RAND()*3), 'Valoración automática de prueba');
            END IF;

            INSERT INTO ConsumoMaterial(cita_id, item_id, cantidad_usada)
            VALUES
                (cita_id_local, 3, 1),
                (cita_id_local, 4, 2);
        END IF;

        SET i = i + 1;
    END WHILE;

    -- Reactivar checks y triggers
    SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;
    SET UNIQUE_CHECKS = @OLD_UNIQUE_CHECKS;
    SET @TRIGGER_DISABLED = FALSE;

END$$

DELIMITER ;

CALL sp_generar_datos_demo_grande();
