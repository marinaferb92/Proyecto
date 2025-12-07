import pandas as pd
import matplotlib.pyplot as plt
from conexion import get_connection
from utils import OUTPUT_DIR
import os

def cargar_productividad():
    conn = get_connection()
    df = pd.read_sql("SELECT * FROM vw_productividad_empleados", conn)
    conn.close()
    return df

def main():
    df = cargar_productividad()
    if df.empty:
        print("No hay datos de productividad todavía.")
        return

    df['tasa_realizacion'] = df['realizadas'] / df['citas_totales'].replace(0, pd.NA)
    df['tasa_realizacion'] = df['tasa_realizacion'].fillna(0)

    out_csv = os.path.join(OUTPUT_DIR, "productividad_empleados.csv")
    df.to_csv(out_csv, index=False)
    print(f"Productividad guardada en {out_csv}")

    # Gráfico
    plt.figure(figsize=(10,4))
    plt.bar(df['nombre'] + ' ' + df['apellido'], df['citas_totales'], label='Citas totales')
    plt.bar(df['nombre'] + ' ' + df['apellido'], df['realizadas'], label='Realizadas', alpha=0.7)
    plt.xticks(rotation=45, ha='right')
    plt.ylabel('Nº citas')
    plt.title('Productividad por empleado')
    plt.legend()
    path_img = os.path.join(OUTPUT_DIR, "productividad_empleados.png")
    plt.tight_layout()
    plt.savefig(path_img)
    plt.close()
    print(f"Gráfico guardado en {path_img}")

if __name__ == "__main__":
    main()
