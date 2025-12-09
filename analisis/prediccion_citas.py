import pandas as pd
import matplotlib.pyplot as plt
from datetime import timedelta
from conexion import get_connection
from utils import OUTPUT_DIR
import os

def cargar_series_citas():
    conn = get_connection()
    query = '''
    SELECT fecha_cita, COUNT(*) AS num_citas
    FROM Citas
    WHERE estado = 'realizada'
    GROUP BY fecha_cita
    ORDER BY fecha_cita
    '''
    df = pd.read_sql(query, conn, parse_dates=['fecha_cita'])
    conn.close()
    return df

def predecir(df, dias_futuro=30, ventana=7):
    # Media móvil como modelo sencillo
    df = df.copy()
    df['pred_base'] = df['num_citas'].rolling(window=ventana, min_periods=1).mean()

    # Último valor de la pred_base
    ultimo_valor = df['pred_base'].iloc[-1]
    ultima_fecha = df['fecha_cita'].iloc[-1]

    fechas_future = [ultima_fecha + timedelta(days=i) for i in range(1, dias_futuro+1)]
    valores_future = [ultimo_valor] * dias_futuro

    df_future = pd.DataFrame({
        'fecha_cita': fechas_future,
        'prediccion': valores_future
    })

    return df, df_future

def generar_grafico(df_hist, df_future):
    plt.figure(figsize=(10,4))
    plt.plot(df_hist['fecha_cita'], df_hist['num_citas'], label='Citas reales')
    plt.plot(df_hist['fecha_cita'], df_hist['pred_base'], label='Media móvil', linestyle='--')
    plt.plot(df_future['fecha_cita'], df_future['prediccion'], label='Predicción', linestyle=':')
    plt.xlabel('Fecha')
    plt.ylabel('Nº citas')
    plt.title('Predicción simple de citas (media móvil)')
    plt.legend()
    path_img = os.path.join(OUTPUT_DIR, "prediccion_citas.png")
    plt.tight_layout()
    plt.savefig(path_img)
    plt.close()
    return path_img

def main():
    df_hist = cargar_series_citas()
    if df_hist.empty:
        print("No hay datos de citas realizadas.")
        return

    df_hist, df_future = predecir(df_hist)
    path_img = generar_grafico(df_hist, df_future)

    # Guardar CSV de predicción
    out_csv = os.path.join(OUTPUT_DIR, "prediccion_citas.csv")
    df_future.to_csv(out_csv, index=False)
    print(f"Predicción futura guardada en {out_csv}")
    print(f"Gráfico guardado en {path_img}")

if __name__ == "__main__":
    main()
