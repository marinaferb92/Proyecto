import pandas as pd
import json
import os
import sys

# Asegurar que Python ve el directorio actual
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.append(BASE_DIR)

from conexion import get_connection
from utils import OUTPUT_DIR


def extraer_datos():
    conn = get_connection()

    datos = {}

    # Total clientes
    clientes = pd.read_sql("SELECT COUNT(*) AS total_clientes FROM Clientes", conn)
    datos["total_clientes"] = int(clientes.iloc[0, 0])

    # Total citas
    citas = pd.read_sql("SELECT COUNT(*) AS total_citas FROM Citas", conn)
    datos["total_citas"] = int(citas.iloc[0, 0])

    # Citas realizadas
    citas_realizadas = pd.read_sql(
        "SELECT COUNT(*) AS realizadas FROM Citas WHERE estado='realizada'",
        conn
    )
    datos["citas_realizadas"] = int(citas_realizadas.iloc[0, 0])

    # Ingresos totales
    ingresos = pd.read_sql("SELECT SUM(monto) AS ingresos FROM Pagos", conn)
    datos["ingresos_totales"] = (
        float(ingresos.iloc[0, 0]) if ingresos.iloc[0, 0] is not None else 0.0
    )

    conn.close()

    # Guardar salida
    path_json = os.path.join(OUTPUT_DIR, "datos_generales.json")
    with open(path_json, "w") as f:
        json.dump(datos, f, indent=4)

    print(f"Datos generales guardados en {path_json}")


if __name__ == "__main__":
    extraer_datos()
