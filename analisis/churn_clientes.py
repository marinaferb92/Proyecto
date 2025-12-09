import os
from datetime import datetime

import pandas as pd

from conexion import get_connection
from utils import OUTPUT_DIR


def analizar_churn(umbral_dias=120):
    conn = get_connection()
    query = """
    SELECT
        c.cliente_id,
        c.nombre,
        c.apellido,
        c.fecha_registro,
        ci.cita_id,
        ci.fecha_cita,
        ci.estado
    FROM Clientes c
    LEFT JOIN Citas ci ON ci.cliente_id = c.cliente_id
    """
    df = pd.read_sql(query, conn, parse_dates=['fecha_registro', 'fecha_cita'])
    conn.close()

    hoy = datetime.today().date()

    # Última cita por cliente
    ultimas = (
        df[df['fecha_cita'].notna()]
        .groupby('cliente_id')['fecha_cita']
        .max()
        .reset_index()
        .rename(columns={'fecha_cita': 'ultima_cita'})
    )

    # Unir con clientes
    clientes = df[['cliente_id', 'nombre', 'apellido', 'fecha_registro']].drop_duplicates()
    res = clientes.merge(ultimas, on='cliente_id', how='left')

    # Calcular recency
    res['recency_dias'] = res['ultima_cita'].apply(
        lambda d: (hoy - d.date()).days if pd.notnull(d) else None
    )

    # Churn: clientes que HAN venido alguna vez y llevan más de umbral_dias sin venir
    def label_churn(row):
        if pd.isna(row['ultima_cita']):
            return 'Nunca ha venido'
        if row['recency_dias'] > umbral_dias:
            return 'En riesgo / posible churn'
        else:
            return 'Activo'

    res['estado_churn'] = res.apply(label_churn, axis=1)

    # Guardar
    out_csv = os.path.join(OUTPUT_DIR, "churn_clientes.csv")
    res.to_csv(out_csv, index=False)
    print(f"[CHURN] Resultados guardados en {out_csv}")

    # Resumen simple
    resumen = res['estado_churn'].value_counts()
    print("[CHURN] Resumen estado clientes:")
    print(resumen)

    return res


if __name__ == "__main__":
    analizar_churn()
