# Laboratorio de limpieza de datos

Material del taller **«Desaprendiendo sobre... Limpieza de datos»** · Máster en Análisis de Datos para la Economía y la Empresa (Universitat de València) · Vicent Correcher.

Seis laboratorios **ya resueltos**: no hay que escribir código. Se ejecuta, se lee lo que sale, se responde a las preguntas de **Para pensar** y se prueba el bloque **Toca esto**. Todos los datos son sintéticos.

## Tres formas de usarlos

### A · En tu ordenador, con RStudio (recomendada)
Necesitas [R](https://cran.r-project.org/) (4.3 o superior) y [RStudio](https://posit.co/download/rstudio-desktop/). Ambos son gratuitos.

1. Descarga los laboratorios en una carpeta **con ruta sin tildes ni eñes**, por ejemplo `C:\labs` (ver «Descargar en tu ordenador», abajo).
2. Haz doble clic en **`laboratorios.Rproj`** (abre RStudio en la carpeta correcta).
3. Abre `lab0_conexion.Rmd`.
4. Ejecuta **celda a celda** con el botón ▶ (o `Ctrl+Enter`), o pulsa **Knit** para generar el informe completo.

La primera celda instala los paquetes que falten y descarga los datos si no están: la primera vez tarda 2-5 minutos. Si prefieres instalarlos antes, abre `instalar_paquetes.R` y pulsa *Source*.

> **Nota para Windows con tildes o eñes en el usuario** (p. ej. `C:\Users\Muñoz`). R puede fallar al hacer *Knit* con `file name conversion problem`. El proyecto incluye un `.Rprofile` que lo evita, pero si aun así te ocurre: ejecuta **celda a celda** (funciona igual) o mueve la carpeta a `C:\labs`.

### Descargar en tu ordenador
Elige una de las tres. Todas dejan la misma carpeta, lista para abrir `laboratorios.Rproj`.

**1 · ZIP, un clic.** [Descargar lab-limpieza-datos.zip](https://github.com/vicentcorrecher/lab-limpieza-datos/archive/refs/heads/main.zip) y descomprímelo en `C:\labs` (o `~/labs` en Mac y Linux). Queda en `lab-limpieza-datos-main`.

**2 · Desde R, sin instalar Git.** Pega esto en la consola de R o RStudio:
```r
dir.create("C:/labs", showWarnings = FALSE)      # en Mac/Linux: "~/labs"
download.file("https://github.com/vicentcorrecher/lab-limpieza-datos/archive/refs/heads/main.zip",
              "C:/labs/lab-limpieza-datos.zip", mode = "wb")
unzip("C:/labs/lab-limpieza-datos.zip", exdir = "C:/labs")
```
Después abre `C:/labs/lab-limpieza-datos-main/laboratorios.Rproj`.

**3 · Con Git (recibes las correcciones con un `git pull`).**
```
git clone https://github.com/vicentcorrecher/lab-limpieza-datos.git C:\labs\lab-limpieza-datos
```
En RStudio: *File → New Project → Version Control → Git* y pega la dirección `https://github.com/vicentcorrecher/lab-limpieza-datos.git`.

### Requisitos y versiones probadas
- **R 4.3 o superior.** Los laboratorios usan el operador `|>` y la sintaxis `\(x)`, que no existen en versiones anteriores. Si tu R es más antiguo, el laboratorio se detiene en la primera celda y te lo dice.
- **Conexión a internet** solo la primera vez, para instalar paquetes. Los datos ya vienen en el ZIP y no se descargan nada si están en `datos/`.
- **Probado con** R 4.6.1 en Windows 11, con tidyverse 2.0.0 (dplyr 1.2.1, readr 2.2.0), DBI 1.3.0, duckdb 1.5.6, mice 3.19.0, rmarkdown 2.32 y knitr 1.52. Los seis laboratorios generan el informe completo en menos de 20 segundos cada uno, y los resultados son idénticos en cada ejecución: los experimentos con azar fijan la semilla y la fecha de corte del laboratorio 5 es fija.
- **Windows, macOS y Linux:** el mismo código funciona en los tres. En Linux se usan binarios precompilados de Posit Package Manager cuando la versión de Ubuntu los ofrece (22.04 y 24.04), y en cualquier otra se instala desde CRAN, más lento.
- **Para pulsar Knit** hace falta pandoc. RStudio lo incluye; con R a secas o VS Code, ejecuta celda a celda o abre los `.html`.

### Si algo falla
| Síntoma | Causa y solución |
|---|---|
| `file name conversion problem -- name too long?` al hacer Knit | Tu usuario de Windows tiene tilde o eñe. Abre el proyecto con `laboratorios.Rproj` (carga el parche de `.Rprofile`) o mueve la carpeta a `C:\labs`. |
| `Estos laboratorios necesitan R 4.3 o superior` | Actualiza R desde [cran.r-project.org](https://cran.r-project.org/). |
| `there is no package called ...` o falla la instalación | Ejecuta `instalar_paquetes.R` con *Source* y mira el mensaje del paquete que falta. |
| No encuentra `datos/...` | Abre el `.Rproj` o fija la carpeta del proyecto como directorio de trabajo; no abras el `.Rmd` suelto desde otra carpeta. |

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
generar_html.R   regenera los .html con la marca (usa assets/)
assets/          marca.css, marca_pie.html y las fuentes Montserrat y DM Sans (licencia OFL) incrustadas en los .html
datos/
  estudiante_18/    5 CSV de una empresa de servicios (2022-2025)
  distribuidora/    dataset sucio a propósito, con su «verdad» (gold standard)
  funciones_labs.R  funciones que usan los laboratorios 2-4
```

Los datos están generados de forma sintética: no representan a ninguna empresa ni persona real.
