import pandas as pd
import matplotlib.pyplot as plt
from conexion import get_connection
from utils import OUTPUT_DIR
import os

def cargar_datos():
    conn = get_connection()
    inv = pd.read_sql("SELECT * FROM Inventario", conn)
    mov = pd.read_sql("SELECT * FROM MovimientosInventario", conn, parse_dates=['fecha_movimiento'])
    conn.close()
    return inv, mov

def analizar_stock(inv, mov):
    # Solo salidas para consumo
    salidas = mov[mov['tipo'] == 'salida'].copy()
    if salidas.empty:
        print("No hay movimientos de salida registrados.")
        return None

    salidas['mes'] = salidas['fecha_movimiento'].dt.to_period('M')
    consumo_mensual = salidas.groupby(['item_id','mes'])['cantidad'].sum().reset_index()

    # Consumo medio mensual por item
    consumo_medio = consumo_mensual.groupby('item_id')['cantidad'].mean().reset_index(name='consumo_medio_mensual')

    resumen = inv.merge(consumo_medio, on='item_id', how='left')
    resumen['consumo_medio_mensual'] = resumen['consumo_medio_mensual'].fillna(0)

    # Meses de cobertura aproximados
    resumen['meses_cobertura'] = resumen.apply(
        lambda row: row['stock_actual'] / row['consumo_medio_mensual'] if row['consumo_medio_mensual'] > 0 else None,
        axis=1
    )
    return resumen

def generar_grafico(resumen):
    criticos = resumen[resumen['stock_actual'] < 10].copy()
    if criticos.empty:
        print("No hay productos con stock crítico.")
        return None
    top = criticos.sort_values('stock_actual').head(15)
    plt.figure(figsize=(10,4))
    plt.bar(top['nombre'], top['stock_actual'])
    plt.xticks(rotation=45, ha='right')
    plt.ylabel('Stock actual')
    plt.title('Productos con stock más crítico')
    path_img = os.path.join(OUTPUT_DIR, "stock_critico.png")
    plt.tight_layout()
    plt.savefig(path_img)
    plt.close()
    return path_img

def main():
    inv, mov = cargar_datos()
    resumen = analizar_stock(inv, mov)
    if resumen is None:
        return
    out_csv = os.path.join(OUTPUT_DIR, "stock_analisis.csv")
    resumen.to_csv(out_csv, index=False)
    print(f"Análisis de stock guardado en {out_csv}")
    img = generar_grafico(resumen)
    if img:
        print(f"Gráfico guardado en {img}")

if __name__ == "__main__":
    main()
