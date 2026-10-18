# Laboratorio de limpieza de datos

Material del taller **«Desaprendiendo sobre... Limpieza de datos»** · Máster en Análisis de Datos para la Economía y la Empresa (Universitat de València) · Vicent Correcher.

Seis laboratorios **ya resueltos**: no hay que escribir código. Se ejecuta, se lee lo que sale, se responde a las preguntas de **Para pensar** y se prueba el bloque **Toca esto**. Todos los datos son sintéticos.

## Cómo abrirlos (sin instalar nada)

1. Pulsa el botón del laboratorio. Se abre en **Google Colab** (hace falta una cuenta de Google).
2. Si Colab no abre el cuaderno con R, ve a *Entorno de ejecución → Cambiar tipo de entorno de ejecución → R*.
3. *Entorno de ejecución → Ejecutar todo*. La primera celda instala paquetes y descarga los datos (1-2 minutos la primera vez).

| Lab | Qué se hace | Datos | Abrir |
|---|---|---|---|
| 0 · Conexión | Qué es cada tabla, relaciones y una base DuckDB conectada | Estudiante_18 | [![Abrir en Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/vicentcorrecher/lab-limpieza-datos/blob/main/lab0_conexion.ipynb) |
| 1 · Auditoría | Cuadro de calidad con semáforo | Estudiante_18 | [![Abrir en Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/vicentcorrecher/lab-limpieza-datos/blob/main/lab1_auditoria.ipynb) |
| 2 · Depuración | Corregir, marcar o preguntar | Estudiante_18 | [![Abrir en Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/vicentcorrecher/lab-limpieza-datos/blob/main/lab2_depuracion.ipynb) |
| 3 · Faltantes | ¿Imputar o no imputar? Experimento MCAR frente a MNAR | Estudiante_18 | [![Abrir en Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/vicentcorrecher/lab-limpieza-datos/blob/main/lab3_faltantes.ipynb) |
| 4 · Impacto en KPIs | ¿Cambian los KPIs al limpiar? | Estudiante_18 | [![Abrir en Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/vicentcorrecher/lab-limpieza-datos/blob/main/lab4_impacto_kpis.ipynb) |
| 5 · Dato sucio | Cuando el dato viene mal de verdad | Distribuidora | [![Abrir en Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/vicentcorrecher/lab-limpieza-datos/blob/main/lab5_dato_sucio.ipynb) |

Cada laboratorio tiene también una versión `.html` con las salidas ya calculadas (para leerla sin ejecutar nada) y el `.qmd` fuente.

## Contenido

```
lab0..lab5   .ipynb (Colab, kernel R) · .html (con salidas) · .qmd (fuente)
datos/
  estudiante_18/    5 CSV de una empresa de servicios (2022-2025)
  distribuidora/    dataset sucio a propósito, con su «verdad» (gold standard)
  funciones_labs.R  funciones que usan los laboratorios 2-4
```

Los datos están generados de forma sintética: no representan a ninguna empresa ni persona real.
