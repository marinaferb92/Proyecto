import pandas as pd
import matplotlib.pyplot as plt
import os
from utils import get_connection

OUTPUT = "informes"
os.makedirs(OUTPUT, exist_ok=True)


def cargar_df(query):
    conn = get_connection()
    df = pd.read_sql(query, conn)
    conn.close()
    return df


def ingresos_mensuales():
    df = cargar_df("SELECT * FROM vw_ingresos_mensuales ORDER BY año_mes")
    plt.figure(figsize=(10, 4))
    plt.plot(df["año_mes"], df["ingresos_totales"], marker="o")
    plt.title("Ingresos Mensuales")
    plt.xlabel("Mes")
    plt.ylabel("Ingresos (€)")
    plt.xticks(rotation=45)
    path = f"{OUTPUT}/ingresos_mensuales.png"
    plt.savefig(path, bbox_inches="tight")
    plt.close()
    return df, path


def tratamientos_mas_usados():
    df = cargar_df("SELECT * FROM vw_tratamientos_mas_demandados LIMIT 10")
    plt.figure(figsize=(10, 4))
    plt.bar(df["nombre"], df["numero_citas"])
    plt.title("Tratamientos más demandados")
    plt.xticks(rotation=45)
    path = f"{OUTPUT}/tratamientos_mas_usados.png"
    plt.savefig(path, bbox_inches="tight")
    plt.close()
    return df, path


def stock_critico():
    df = cargar_df("SELECT * FROM vw_stock_critico")
    return df


def productividad_empleados():
    df = cargar_df("SELECT * FROM vw_productividad_empleados")
    return df


def generar_html(df_ing, img1, df_trat, img2, df_stock, df_prod):
    html = f"""
    <html>
    <head>
        <meta charset='UTF-8'>
        <title>Informe Clínica</title>
        <style>
            body {{ font-family: Arial; margin: 40px; }}
            h1 {{ color: #246; }}
            img {{ width: 600px; margin-top: 10px; }}
            table {{ border-collapse: collapse; width: 80%; }}
            td, th {{ border: 1px solid #ccc; padding: 5px; }}
        </style>
    </head>
    <body>
        <h1>📊 Informe automático - Clínica Estética</h1>

        <h2>Ingresos mensuales</h2>
        <img src='{img1}'>
        {df_ing.to_html(index=False)}

        <h2>Tratamientos más demandados</h2>
        <img src='{img2}'>
        {df_trat.to_html(index=False)}

        <h2>Stock crítico</h2>
        {df_stock.to_html(index=False)}

        <h2>Productividad empleados</h2>
        {df_prod.to_html(index=False)}

        <hr>
        <p>Generado automáticamente con Python.</p>
    </body>
    </html>
    """

    path = f"{OUTPUT}/informe_clinica.html"
    with open(path, "w", encoding="utf-8") as f:
        f.write(html)

    print(f"📄 Informe generado en: {path}")


def main():
    df_ing, img1 = ingresos_mensuales()
    df_trat, img2 = tratamientos_mas_usados()
    df_stock = stock_critico()
    df_prod = productividad_empleados()

    generar_html(df_ing, img1, df_trat, img2, df_stock, df_prod)


if __name__ == "__main__":
    main()
