import os

import matplotlib.pyplot as plt
import pandas as pd
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler

from analisis_rfm import calcular_rfm
from utils import OUTPUT_DIR


def clustering_clientes(k=4):
    # Reutilizamos el cálculo RFM
    rfm = calcular_rfm()
    if rfm is None or rfm.empty:
        print("No se pudo calcular RFM, no hay datos suficientes.")
        return

    # Seleccionamos solo las métricas numéricas
    X = rfm[['recency_days', 'frequency', 'monetary']].copy()

    # Escalar (muy importante para K-Means)
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)

    # Aplicar K-Means
    kmeans = KMeans(n_clusters=k, random_state=42, n_init="auto")
    rfm['cluster'] = kmeans.fit_predict(X_scaled)

    # Podemos ordenar los clusters por valor medio monetario para interpretarlos
    cluster_stats = (
        rfm.groupby('cluster')[['recency_days', 'frequency', 'monetary']]
        .mean()
        .sort_values('monetary', ascending=False)
    )
    cluster_stats.reset_index(inplace=True)
    cluster_stats['cluster_nombre'] = ['Cluster ' + str(i) for i in range(len(cluster_stats))]

    # Unir etiquetas interpretables
    map_order = {row['cluster']: row['cluster_nombre'] for _, row in cluster_stats.iterrows()}
    rfm['cluster_nombre'] = rfm['cluster'].map(map_order)

    # Guardar CSV
    out_csv = os.path.join(OUTPUT_DIR, "clustering_clientes.csv")
    rfm.to_csv(out_csv, index=False)
    print(f"[CLUSTER] Resultados guardados en {out_csv}")

    # Gráfico 2D: frecuencia vs monetario coloreado por cluster
    plt.figure(figsize=(8, 5))
    for c in sorted(rfm['cluster'].unique()):
        sub = rfm[rfm['cluster'] == c]
        plt.scatter(sub['frequency'], sub['monetary'], label=f"Cluster {c}", alpha=0.7)

    plt.xlabel("Frecuencia (nº citas)")
    plt.ylabel("Monetary (ingresos totales)")
    plt.title("Clusterización de clientes (K-Means)")
    plt.legend()
    out_img = os.path.join(OUTPUT_DIR, "clustering_clientes.png")
    plt.tight_layout()
    plt.savefig(out_img)
    plt.close()
    print(f"[CLUSTER] Gráfico guardado en {out_img}")

    return rfm, cluster_stats


if __name__ == "__main__":
    clustering_clientes()
