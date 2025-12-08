SET @TRIGGER_DISABLED = TRUE;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- EMPLEADOS
-- ============================================================
INSERT IGNORE INTO Empleados (empleado_id, nombre, apellido, fecha_ingreso, telefono, email, categoria_id, activo) VALUES
(1,'María','García','2021-06-10','600111111','maria@clinica.com',1,1),
(2,'Laura','Fernández','2022-02-15','600222222','laura@clinica.com',1,1),
(3,'Ana','Santos','2020-09-20','600333333','ana@clinica.com',2,1),
(4,'Carmen','Martín','2019-04-12','600444444','carmen@clinica.com',3,1),
(5,'Lucía','Navarro','2023-01-30','600555555','lucia@clinica.com',4,1),
(6,'Sofía','Romero','2018-11-05','600666666','sofia@clinica.com',5,1);

-- ============================================================
-- SALAS
-- ============================================================
INSERT IGNORE INTO Salas (sala_id,nombre,tipo,capacidad) VALUES
(1,'Sala Facial','Tratamiento',1),
(2,'Sala Corporal','Tratamiento',1),
(3,'Cabina Láser','Láser',1),
(4,'Consulta Médica','Consulta',2),
(5,'Sala Relax','Cabina',1);

-- ============================================================
-- TRATAMIENTOS
-- ============================================================
INSERT IGNORE INTO Tratamientos (tratamiento_id,nombre,descripcion,precio,duracion_min,categoria_id,requiere_sala) VALUES
(1,'Limpieza profunda','Facial',60,60,1,1),
(2,'Peeling químico','Facial',80,45,1,1),
(3,'Masaje reductor','Corporal',70,60,2,1),
(4,'Radiofrecuencia','Facial',90,50,4,1),
(5,'Láser piernas','Depilación',150,75,3,1),
(6,'Láser axilas','Depilación',50,30,3,1),
(7,'Anti-edad premium','Facial avanzado',180,90,4,1),
(8,'Masaje relajante','Bienestar',55,50,5,1),
(9,'LPG corporal','Remodelación',95,60,2,1),
(10,'Láser manchas','Láser',130,45,3,1);

-- ============================================================
-- INVENTARIO
-- ============================================================
INSERT IGNORE INTO Inventario (item_id,nombre,tipo,stock_actual,unidad,costo_unitario)
VALUES
(1,'Guantes nitrilo','insumo',300,'caja',5),
(2,'Gasas estériles','insumo',500,'paquete',3.5),
(3,'Sérum facial','producto',80,'uds',20),
(4,'Crema facial','producto',50,'uds',12),
(5,'Mascarilla colágeno','insumo',120,'uds',4.5),
(6,'Ácido hialurónico','producto',30,'vial',90),
(7,'Toallas desechables','insumo',200,'paquete',8),
(8,'Gel conductor','insumo',150,'bote',6),
(9,'Agujas mesoterapia','insumo',300,'uds',1),
(10,'Ampollas vitamina C','insumo',100,'ampolla',9);

-- ============================================================
-- CLIENTES (2000) — usando WHILE
-- ============================================================
DROP PROCEDURE IF EXISTS gen_clientes;
DELIMITER $$

CREATE PROCEDURE gen_clientes()
BEGIN
  DECLARE i INT DEFAULT 1;

  WHILE i <= 2000 DO
    INSERT INTO Clientes(dni,nombre,apellido,fecha_nacimiento,edad,genero,telefono,correo,direccion,fecha_registro,origen_cliente)
    VALUES(
      CONCAT('DNI',LPAD(FLOOR(RAND()*90000000)+10000000,8,'0')),
      CONCAT('Nombre',i),
      CONCAT('Apellido',i),
      DATE_SUB(CURDATE(),INTERVAL FLOOR(RAND()*40+18) YEAR),
      FLOOR(RAND()*40+18),
      ELT(FLOOR(RAND()*3)+1,'Hombre','Mujer','Otro'),
      CONCAT('+34 6',LPAD(FLOOR(RAND()*10000000),7,'0')),
      CONCAT('cliente',i,'@mail.com'),
      CONCAT('Calle ',i,' Madrid'),
      DATE_SUB(CURDATE(),INTERVAL FLOOR(RAND()*365) DAY),
      ELT(FLOOR(RAND()*5)+1,'Google','Instagram','Recomendacion','Web','Publicidad')
    );
    SET i = i + 1;
  END WHILE;
END$$
DELIMITER ;

CALL gen_clientes();
DROP PROCEDURE gen_clientes;

-- ============================================================
-- CITAS (5000)
-- ============================================================
DROP PROCEDURE IF EXISTS gen_citas;
DELIMITER $$

CREATE PROCEDURE gen_citas()
BEGIN
  DECLARE i INT DEFAULT 1;

  WHILE i <= 5000 DO
    INSERT INTO Citas(cliente_id,empleado_id,tratamiento_id,sala_id,fecha_cita,hora_cita,estado,observaciones)
    VALUES(
      FLOOR(RAND()*2000)+1,
      FLOOR(RAND()*6)+1,
      FLOOR(RAND()*10)+1,
      FLOOR(RAND()*5)+1,
      DATE_SUB(CURDATE(),INTERVAL FLOOR(RAND()*150) DAY),
      MAKETIME(FLOOR(RAND()*8)+9, IF(RAND()>0.5,0,30), 0),
      ELT(FLOOR(RAND()*5)+1,'pendiente','confirmada','realizada','cancelada','reprogramada'),
      'Cita generada automáticamente'
    );
    SET i = i + 1;
  END WHILE;
END$$
DELIMITER ;

CALL gen_citas();
DROP PROCEDURE gen_citas;

-- ============================================================
-- PAGOS (3500)
-- ============================================================
INSERT INTO Pagos(cita_id,metodo_pago,monto,fecha_pago)
SELECT
  cita_id,
  ELT(FLOOR(RAND()*4)+1,'efectivo','tarjeta','transferencia','bizum'),
  (SELECT precio FROM Tratamientos t WHERE t.tratamiento_id=c.tratamiento_id),
  CONCAT(fecha_cita,' ',hora_cita)
FROM Citas c
ORDER BY RAND()
LIMIT 3500;

-- ============================================================
-- CONSUMO MATERIAL (1000)
-- ============================================================
INSERT INTO ConsumoMaterial(cita_id,item_id,cantidad_usada)
SELECT
  cita_id,
  FLOOR(RAND()*10)+1,
  FLOOR(RAND()*3)+1
FROM Citas
ORDER BY RAND()
LIMIT 1000;

SET FOREIGN_KEY_CHECKS = 1;
SET @TRIGGER_DISABLED = FALSE;
