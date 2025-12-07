import pandas as pd
import matplotlib.pyplot as plt
from conexion import get_connection
from utils import OUTPUT_DIR
import os

def cargar_datos():
    conn = get_connection()
    query = '''
    SELECT
        t.tratamiento_id,
        t.nombre AS tratamiento,
        c.cita_id,
        c.fecha_cita,
        p.monto AS ingreso,
        cm.cantidad_usada,
        i.costo_unitario
    FROM Tratamientos t
    LEFT JOIN Citas c ON c.tratamiento_id = t.tratamiento_id
    LEFT JOIN Pagos p ON p.cita_id = c.cita_id
    LEFT JOIN ConsumoMaterial cm ON cm.cita_id = c.cita_id
    LEFT JOIN Inventario i ON i.item_id = cm.item_id
    '''
    df = pd.read_sql(query, conn)
    conn.close()
    return df

def calcular_rentabilidad(df):
    df = df.copy()
    # Coste material por fila
    df['coste_material'] = df['cantidad_usada'] * df['costo_unitario']

    # Agrupar por cita y tratamiento
    agg = df.groupby(['tratamiento_id','tratamiento','cita_id'], dropna=False).agg({
        'ingreso':'sum',
        'coste_material':'sum'
    }).reset_index()

    # Agrupar por tratamiento
    resumen = agg.groupby(['tratamiento_id','tratamiento']).agg({
        'ingreso':'sum',
        'coste_material':'sum',
        'cita_id':'count'
    }).rename(columns={'cita_id':'num_citas'}).reset_index()

    resumen['beneficio'] = resumen['ingreso'] - resumen['coste_material']
    resumen = resumen.sort_values('beneficio', ascending=False)
    return resumen

def generar_grafico(resumen):
    top = resumen.head(10)
    plt.figure(figsize=(10,4))
    plt.bar(top['tratamiento'], top['beneficio'])
    plt.xticks(rotation=45, ha='right')
    plt.ylabel('Beneficio (€)')
    plt.title('Top 10 tratamientos más rentables')
    path_img = os.path.join(OUTPUT_DIR, "tratamientos_rentables.png")
    plt.tight_layout()
    plt.savefig(path_img)
    plt.close()
    return path_img

def main():
    df = cargar_datos()
    if df.empty:
        print("No hay datos suficientes de tratamientos.")
        return
    resumen = calcular_rentabilidad(df)
    out_csv = os.path.join(OUTPUT_DIR, "tratamientos_rentables.csv")
    resumen.to_csv(out_csv, index=False)
    print(f"Rentabilidad de tratamientos guardada en {out_csv}")
    img = generar_grafico(resumen)
    print(f"Gráfico guardado en {img}")

if __name__ == "__main__":
    main()