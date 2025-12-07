import csv
import os
from utils import get_connection

# Carpetas de salida
OUTPUT_DIR = "csv"
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Tablas que quieres exportar
TABLAS = [
    "Clientes",
    "Empleados",
    "Tratamientos",
    "Citas",
    "Pagos",
    "Inventario",
    "Proveedores",
    "MovimientosInventario",
    "DescuentosPromociones",
    "CampañasMarketing"
]

# Vistas útiles para análisis
VISTAS = [
    "vw_ingresos_mensuales",
    "vw_tratamientos_mas_demandados",
    "vw_stock_critico",
    "vw_productividad_empleados"
]

def exportar(nombre, tipo="tabla"):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    print(f"📤 Exportando {tipo}: {nombre} ...")

    cursor.execute(f"SELECT * FROM {nombre}")
    filas = cursor.fetchall()

    if filas:
        columnas = filas[0].keys()
    else:
        columnas = []

    path = os.path.join(OUTPUT_DIR, f"{nombre}.csv")
    with open(path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=columnas)
        writer.writeheader()
        writer.writerows(filas)

    print(f"   → Guardado en {path}")

    cursor.close()
    conn.close()


def main():
    print("========== EXPORTACIÓN DE DATOS ==========")

    for tabla in TABLAS:
        exportar(tabla, "tabla")

    for vista in VISTAS:
        exportar(vista, "vista")

    print("\n🎉 Exportación completada.\nLos CSV están listos para PowerBI / análisis Python.")


if __name__ == "__main__":
    main()
