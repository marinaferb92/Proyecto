import pandas as pd
from conexion import get_connection
from utils import OUTPUT_DIR

db = get_connection()
query = """
SELECT 
    e.empleado_id,
    CONCAT(e.nombre, ' ', e.apellido) AS empleado,
    COUNT(c.cita_id) AS citas_totales,
    SUM(c.estado = 'realizada') AS citas_realizadas
FROM Empleados e
LEFT JOIN Citas c ON c.empleado_id = e.empleado_id
GROUP BY e.empleado_id
ORDER BY citas_realizadas DESC;
"""

df = pd.read_sql(query, db)
df.to_csv(f"{OUTPUT_DIR}/productividad.csv", index=False)
print("✔ productividad.csv generado")
