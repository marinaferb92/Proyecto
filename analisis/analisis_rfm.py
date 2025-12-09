import pandas as pd
from datetime import datetime
from conexion import get_connection
from utils import OUTPUT_DIR
import os

def calcular_rfm():
    conn = get_connection()

    query = '''
    SELECT
        c.cliente_id,
        c.nombre,
        c.apellido,
        c.fecha_registro,
        ci.cita_id,
        ci.fecha_cita,
        ci.estado,
        p.monto,
        p.fecha_pago
    FROM Clientes c
    LEFT JOIN Citas ci ON ci.cliente_id = c.cliente_id
    LEFT JOIN Pagos p ON p.cita_id = ci.cita_id
    '''

    df = pd.read_sql(query, conn)
    conn.close()

    # Conversión segura a datetime
    df['fecha_cita'] = pd.to_datetime(df['fecha_cita'], errors='coerce')
    df = df.dropna(subset=['fecha_cita'])

    # Hoy como datetime
    hoy = pd.to_datetime(datetime.today().date())

    # Citas realizadas
    realizadas = df[df['estado'] == 'realizada'].copy()

    if realizadas.empty:
        print("No hay citas realizadas todavía para calcular RFM.")
        return

    # Última cita del cliente
    ultimas = realizadas.groupby('cliente_id')['fecha_cita'].max().reset_index()

    # ➤ CÁLCULO CORRECTO DE RECENCY (ya no da error)
    ultimas['recency_days'] = (hoy - ultimas['fecha_cita']).dt.days

    # Frecuencia
    freq = realizadas.groupby('cliente_id')['cita_id'].nunique().reset_index(name='frequency')

    # Monetario
    pagos = realizadas.dropna(subset=['monto']) \
                      .groupby('cliente_id')['monto'] \
                      .sum().reset_index(name='monetary')

    # Unir
    rfm = ultimas.merge(freq, on='cliente_id', how='left').merge(pagos, on='cliente_id', how='left')

    # Añadir datos cliente
    base = df[['cliente_id','nombre','apellido']].drop_duplicates()
    rfm = rfm.merge(base, on='cliente_id', how='left')

    # Rellenar faltantes
    rfm['monetary'] = rfm['monetary'].fillna(0)

    # Scores
    rfm['R_score'] = pd.qcut(rfm['recency_days'], 5, labels=[5,4,3,2,1]).astype(int)
    rfm['F_score'] = pd.qcut(rfm['frequency'].rank(method='first'), 5, labels=[1,2,3,4,5]).astype(int)
    rfm['M_score'] = pd.qcut(rfm['monetary'].rank(method='first'), 5, labels=[1,2,3,4,5]).astype(int)

    rfm['RFM_score'] = rfm[['R_score','F_score','M_score']].sum(axis=1)

    def segment(row):
        if row['RFM_score'] >= 13: return 'VIP'
        if row['RFM_score'] >= 10: return 'Leales'
        if row['RFM_score'] >= 7:  return 'En crecimiento'
        if row['RFM_score'] >= 4:  return 'En riesgo'
        return 'Dormidos'

    rfm['segmento'] = rfm.apply(segment, axis=1)

    # Guardar
    out = os.path.join(OUTPUT_DIR, "rfm_clientes.csv")
    rfm.to_csv(out, index=False)
    print(f"RFM guardado en {out}")

    return rfm

if __name__ == "__main__":
    calcular_rfm()
