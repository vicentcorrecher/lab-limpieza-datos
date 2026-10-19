# Laboratorio de limpieza de datos

Material del taller **«Desaprendiendo sobre... Limpieza de datos»** · Máster en Análisis de Datos para la Economía y la Empresa (Universitat de València) · Vicent Correcher.

Seis laboratorios **ya resueltos**: no hay que escribir código. Se ejecuta, se lee lo que sale, se responde a las preguntas de **Para pensar** y se prueba el bloque **Toca esto**. Todos los datos son sintéticos.

## Tres formas de usarlos

### A · En tu ordenador, con RStudio (recomendada)
Necesitas [R](https://cran.r-project.org/) (4.3 o superior) y [RStudio](https://posit.co/download/rstudio-desktop/). Ambos son gratuitos.

1. Pulsa el botón verde **Code → Download ZIP** y descomprímelo en una carpeta **con ruta sin tildes ni eñes**, por ejemplo `C:\labs`.
2. Haz doble clic en **`laboratorios.Rproj`** (abre RStudio en la carpeta correcta).
3. Abre `lab0_conexion.Rmd`.
4. Ejecuta **celda a celda** con el botón ▶ (o `Ctrl+Enter`), o pulsa **Knit** para generar el informe completo.

La primera celda instala los paquetes que falten y descarga los datos si no están: la primera vez tarda 2-5 minutos. Si prefieres instalarlos antes, abre `instalar_paquetes.R` y pulsa *Source*.

> Si el botón **Knit** falla con `file name conversion problem`, la ruta de la carpeta tiene tildes o eñes (p. ej. `C:\Users\Muñoz`). Mueve la carpeta a `C:\labs` o ejecuta celda a celda, que funciona igual.

### B · Solo leer, sin instalar nada
Cada laboratorio tiene su `.html` con todas las salidas ya calculadas. Se abren en cualquier navegador.

### C · En Google Colab
Es opcional: a veces tarda en conectar el entorno de R.

| Lab | Qué se hace | Datos | Colab |
|---|---|---|---|
| 0 · Conexión | Qué es cada tabla, relaciones y una base DuckDB conectada | Estudiante_18 | [![Abrir en Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/vicentcorrecher/lab-limpieza-datos/blob/main/lab0_conexion.ipynb) |
| 1 · Auditoría | Cuadro de calidad con semáforo | Estudiante_18 | [![Abrir en Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/vicentcorrecher/lab-limpieza-datos/blob/main/lab1_auditoria.ipynb) |
| 2 · Depuración | Corregir, marcar o preguntar | Estudiante_18 | [![Abrir en Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/vicentcorrecher/lab-limpieza-datos/blob/main/lab2_depuracion.ipynb) |
| 3 · Faltantes | ¿Imputar o no imputar? Experimento MCAR frente a MNAR | Estudiante_18 | [![Abrir en Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/vicentcorrecher/lab-limpieza-datos/blob/main/lab3_faltantes.ipynb) |
| 4 · Impacto en KPIs | ¿Cambian los KPIs al limpiar? | Estudiante_18 | [![Abrir en Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/vicentcorrecher/lab-limpieza-datos/blob/main/lab4_impacto_kpis.ipynb) |
| 5 · Dato sucio | Cuando el dato viene mal de verdad | Distribuidora | [![Abrir en Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/vicentcorrecher/lab-limpieza-datos/blob/main/lab5_dato_sucio.ipynb) |

En Colab: *Entorno de ejecución → Cambiar tipo de entorno de ejecución → R*, y después *Ejecutar todo*.

## Contenido

```
lab0..lab5     .Rmd (RStudio) · .html (con salidas) · .ipynb (Colab, kernel R)
laboratorios.Rproj · instalar_paquetes.R
datos/
  estudiante_18/    5 CSV de una empresa de servicios (2022-2025)
  distribuidora/    dataset sucio a propósito, con su «verdad» (gold standard)
  funciones_labs.R  funciones que usan los laboratorios 2-4
```

Los datos están generados de forma sintética: no representan a ninguna empresa ni persona real.
