import pandas as pd
from conexion import get_connection
from utils import OUTPUT_DIR

db = get_connection()
query = """
SELECT item_id, nombre, stock_actual, unidad, tipo
FROM Inventario
WHERE stock_actual < 10
ORDER BY stock_actual ASC;
"""
df = pd.read_sql(query, db)
df.to_csv(f"{OUTPUT_DIR}/stock_bajo.csv", index=False)
print("✔ stock_bajo.csv generado")
