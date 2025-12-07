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

    # Fecha de referencia = hoy (se puede fijar manual)
    hoy = datetime.today().date()

    # Solo citas realizadas para métricas principales
    realizadas = df[df['estado'] == 'realizada'].copy()

    # Si no hay datos todavía, devolvemos vacío
    if realizadas.empty:
        print("No hay citas realizadas todavía para calcular RFM.")
        return

    # Ultima cita por cliente
    ultimas = realizadas.groupby('cliente_id')['fecha_cita'].max().reset_index()
    ultimas['recency_days'] = (hoy - ultimas['fecha_cita']).dt.days

    # Frecuencia = nº de citas realizadas
    freq = realizadas.groupby('cliente_id')['cita_id'].nunique().reset_index(name='frequency')

    # Monetario = suma de pagos
    pagos = realizadas.dropna(subset=['monto']).groupby('cliente_id')['monto'].sum().reset_index(name='monetary')

    # Unimos todo
    rfm = ultimas.merge(freq, on='cliente_id', how='left').merge(pagos, on='cliente_id', how='left')

    # Añadimos nombre y apellido
    base_cli = df[['cliente_id','nombre','apellido']].drop_duplicates()
    rfm = rfm.merge(base_cli, on='cliente_id', how='left')

    # Rellenar NaN monetario con 0
    rfm['monetary'] = rfm['monetary'].fillna(0)

    # Ranking en cuartiles/quintiles
    rfm['R_score'] = pd.qcut(rfm['recency_days'], 5, labels=[5,4,3,2,1]).astype(int)  # menor recency = mejor
    rfm['F_score'] = pd.qcut(rfm['frequency'].rank(method='first'), 5, labels=[1,2,3,4,5]).astype(int)
    rfm['M_score'] = pd.qcut(rfm['monetary'].rank(method='first'), 5, labels=[1,2,3,4,5]).astype(int)

    rfm['RFM_score'] = rfm['R_score'] + rfm['F_score'] + rfm['M_score']

    # Segmento simplificado
    def segment(row):
        if row['RFM_score'] >= 13:
            return 'VIP'
        elif row['RFM_score'] >= 10:
            return 'Leales'
        elif row['RFM_score'] >= 7:
            return 'En crecimiento'
        elif row['RFM_score'] >= 4:
            return 'En riesgo'
        else:
            return 'Dormidos'

    rfm['segmento'] = rfm.apply(segment, axis=1)

    # Guardar CSV
    path_csv = os.path.join(OUTPUT_DIR, "rfm_clientes.csv")
    rfm.to_csv(path_csv, index=False)
    print(f"RFM guardado en {path_csv}")

    return rfm


if __name__ == "__main__":
    calcular_rfm()
