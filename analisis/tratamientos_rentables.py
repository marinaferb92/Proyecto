import pandas as pd
from conexion import get_connection
from utils import OUTPUT_DIR

db = get_connection()
query = """
SELECT 
    t.nombre AS tratamiento,
    COUNT(c.cita_id) AS numero_citas,
    t.precio * COUNT(c.cita_id) AS rentabilidad
FROM Tratamientos t
LEFT JOIN Citas c ON c.tratamiento_id = t.tratamiento_id
GROUP BY t.tratamiento_id
ORDER BY rentabilidad DESC;
"""

df = pd.read_sql(query, db)
df.to_csv(f"{OUTPUT_DIR}/tratamientos_rentables.csv", index=False)
print("✔ tratamientos_rentables.csv generado")
