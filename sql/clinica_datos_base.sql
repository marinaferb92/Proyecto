USE clinica_db;

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

-- Empleados (10 empleados de ejemplo)
INSERT INTO Empleados(nombre, apellido, fecha_ingreso, telefono, email, categoria_id, activo) VALUES
('Laura','Médica', DATE_SUB(CURDATE(), INTERVAL 400 DAY), '+34 600000001','laura.medica@clinica.com',1,TRUE),
('Ana','Médica', DATE_SUB(CURDATE(), INTERVAL 380 DAY), '+34 600000002','ana.medica@clinica.com',1,TRUE),
('Carlos','Médico', DATE_SUB(CURDATE(), INTERVAL 360 DAY), '+34 600000003','carlos.medico@clinica.com',1,TRUE),
('Marta','Esteticista', DATE_SUB(CURDATE(), INTERVAL 300 DAY), '+34 600000004','marta.esteticista@clinica.com',2,TRUE),
('Lucía','Esteticista', DATE_SUB(CURDATE(), INTERVAL 280 DAY), '+34 600000005','lucia.esteticista@clinica.com',2,TRUE),
('Paula','Esteticista', DATE_SUB(CURDATE(), INTERVAL 260 DAY), '+34 600000006','paula.esteticista@clinica.com',2,TRUE),
('Sara','Recepcionista', DATE_SUB(CURDATE(), INTERVAL 240 DAY), '+34 600000007','sara.recepcion@clinica.com',3,TRUE),
('Irene','Recepcionista', DATE_SUB(CURDATE(), INTERVAL 220 DAY), '+34 600000008','irene.recepcion@clinica.com',3,TRUE),
('Javier','Médico', DATE_SUB(CURDATE(), INTERVAL 200 DAY), '+34 600000009','javier.medico@clinica.com',1,TRUE),
('Diego','Médico', DATE_SUB(CURDATE(), INTERVAL 180 DAY), '+34 600000010','diego.medico@clinica.com',1,TRUE)
ON DUPLICATE KEY UPDATE email = VALUES(email);

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
