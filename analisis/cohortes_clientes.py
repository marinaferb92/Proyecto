import os

import pandas as pd

from conexion import get_connection
from utils import OUTPUT_DIR


def cargar_citas():
    conn = get_connection()
    query = """
    SELECT
        c.cliente_id,
        c.nombre,
        c.apellido,
        ci.cita_id,
        ci.fecha_cita,
        ci.estado
    FROM Clientes c
    JOIN Citas ci ON ci.cliente_id = c.cliente_id
    WHERE ci.estado = 'realizada'
    """
    df = pd.read_sql(query, conn, parse_dates=['fecha_cita'])
    conn.close()
    return df


def construir_cohortes(df):
    df = df.copy()
    # Mes de la primera cita (cohort_month)
    df['cohort_month'] = df.groupby('cliente_id')['fecha_cita'].transform('min').dt.to_period('M')
    df['cita_month'] = df['fecha_cita'].dt.to_period('M')

    # Periodo = nº de meses desde la cohorte
    df['periodo'] = (df['cita_month'] - df['cohort_month']).apply(lambda p: p.n)

    # Tabla de tamaño de cohortes (clientes únicos por cohorte)
    cohort_size = (
        df.groupby('cohort_month')['cliente_id']
        .nunique()
        .reset_index()
        .rename(columns={'cliente_id': 'num_clientes'})
    )

    # Clientes activos por cohorte y periodo
    cohort_data = (
        df.groupby(['cohort_month', 'periodo'])['cliente_id']
        .nunique()
        .reset_index()
        .rename(columns={'cliente_id': 'clientes_activos'})
    )

    # Unir tamaño de cohorte
    cohort_data = cohort_data.merge(cohort_size, on='cohort_month', how='left')
    cohort_data['tasa_retencion'] = cohort_data['clientes_activos'] / cohort_data['num_clientes']

    return cohort_data, cohort_size


def main():
    df = cargar_citas()
    if df.empty:
        print("No hay citas realizadas para análisis de cohortes.")
        return

    cohort_data, cohort_size = construir_cohortes(df)

    out_csv = os.path.join(OUTPUT_DIR, "cohortes_retencion.csv")
    cohort_data.to_csv(out_csv, index=False)
    print(f"[COHORTES] Datos de retención guardados en {out_csv}")

    out_csv2 = os.path.join(OUTPUT_DIR, "cohortes_tamano.csv")
    cohort_size.to_csv(out_csv2, index=False)
    print(f"[COHORTES] Tamaño de cohortes guardado en {out_csv2}")

    # (Opcional) También se podrían hacer heatmaps, pero eso es más visual para PowerBI.
    print("[COHORTES] Usa estos CSV en Power BI para crear un mapa de calor de retención por cohorte/mes.")


if __name__ == "__main__":
    main()
