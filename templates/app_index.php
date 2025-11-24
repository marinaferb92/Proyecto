<?php
$conexion = new mysqli("{{ db.backend1_ip }}", "{{ db.user }}", "{{ db.password }}", "{{ db.name }}");

if ($conexion->connect_error) {
    die("Error conectando a la BD: " . $conexion->connect_error);
}

echo "<h1>Clínica Estética - Portal Interno</h1>";
echo "<p>Conexión a base de datos correcta.</p>";
?>
