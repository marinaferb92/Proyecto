import pandas as pd
import matplotlib.pyplot as plt
from conexion import get_connection
from utils import OUTPUT_DIR
import os

def cargar_datos():
    conn = get_connection()
    campanias = pd.read_sql("SELECT * FROM CampañasMarketing", conn)
    clientes = pd.read_sql("SELECT origen_cliente FROM Clientes", conn)
    conn.close()
    return campanias, clientes

def analizar(campanias, clientes):
    # Conteo de clientes por origen_cliente
    origen_counts = clientes['origen_cliente'].value_counts().reset_index()
    origen_counts.columns = ['canal', 'num_clientes']

    # Agrupamos campañas por canal
    camp_group = campanias.groupby('canal').agg({
        'presupuesto':'sum'
    }).reset_index()

    # Mezclamos
    resumen = camp_group.merge(origen_counts, on='canal', how='left')
    resumen['num_clientes'] = resumen['num_clientes'].fillna(0)

    # Coste aproximado por cliente captado
    resumen['coste_por_cliente'] = resumen.apply(
        lambda row: row['presupuesto'] / row['num_clientes'] if row['num_clientes'] > 0 else None,
        axis=1
    )
    return resumen

def generar_grafico(resumen):
    plt.figure(figsize=(10,4))
    plt.bar(resumen['canal'], resumen['num_clientes'])
    plt.xticks(rotation=45, ha='right')
    plt.ylabel('Nº clientes')
    plt.title('Clientes captados por canal')
    path_img = os.path.join(OUTPUT_DIR, "campanias_clientes.png")
    plt.tight_layout()
    plt.savefig(path_img)
    plt.close()
    return path_img

def main():
    campanias, clientes = cargar_datos()
    if campanias.empty:
        print("No hay campañas registradas.")
        return
    resumen = analizar(campanias, clientes)
    out_csv = os.path.join(OUTPUT_DIR, "campanias_efectividad.csv")
    resumen.to_csv(out_csv, index=False)
    print(f"Efectividad de campañas guardada en {out_csv}")
    img = generar_grafico(resumen)
    print(f"Gráfico guardado en {img}")

if __name__ == "__main__":
    main()
