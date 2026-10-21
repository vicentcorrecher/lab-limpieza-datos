# Laboratorio de limpieza de datos

Material del taller **«Desaprendiendo sobre... Limpieza de datos»** · Máster en Análisis de Datos para la Economía y la Empresa (Universitat de València) · Vicent Correcher.

Seis laboratorios **ya resueltos**: no hay que escribir código. Se ejecuta, se lee lo que sale, se responde a las preguntas de **Para pensar** y se prueba el bloque **Toca esto**. Todos los datos son sintéticos.

## Descargar en tu ordenador
Elige una de las tres. Todas dejan la misma carpeta, lista para abrir `laboratorios.Rproj`. Guárdala en una ruta **sin tildes ni eñes**, por ejemplo `C:\labs`.

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

## Cuatro formas de usarlos

| Quiero... | Abro | Carpeta |
|---|---|---|
| Ejecutar el laboratorio en RStudio, celda a celda o con *Knit* | `lab0_conexion.Rmd`... | `rmarkdown/` |
| Ir **paso a paso en código**, con el texto del laboratorio en comentarios | `lab0_conexion.R`... | `R/` |
| **Solo leer**, sin instalar nada, con todas las salidas | `lab0_conexion.html`... en el navegador | `html/` |
| Trabajar en la nube, sin instalar R | los cuadernos de Colab | `google_colab/` |

### A · RStudio con los `.Rmd` (recomendada)
Necesitas [R](https://cran.r-project.org/) (4.3 o superior) y [RStudio](https://posit.co/download/rstudio-desktop/). Ambos son gratuitos.

1. Haz doble clic en **`laboratorios.Rproj`** (abre RStudio en la carpeta correcta).
2. Abre `rmarkdown/lab0_conexion.Rmd`.
3. Ejecuta **celda a celda** con el botón ▶ (o `Ctrl+Enter`), o pulsa **Knit** para generar el informe completo, que se guarda en `html/`.

La primera celda instala los paquetes que falten y descarga los datos si no están: la primera vez tarda 2-5 minutos. Si prefieres instalarlos antes, abre `instalar_paquetes.R` y pulsa *Source*.

> **Nota para Windows con tildes o eñes en el usuario** (p. ej. `C:\Users\Muñoz`). R puede fallar al hacer *Knit* con `file name conversion problem`. El proyecto incluye un `.Rprofile` que lo evita, pero si aun así te ocurre: ejecuta **celda a celda** (funciona igual) o mueve la carpeta a `C:\labs`.

### B · Paso a paso en código (`R/`)
Un guion por laboratorio (`R/lab0_conexion.R`...). El texto del laboratorio —explicaciones, **Para pensar** y **Toca esto**— está en los comentarios que empiezan por `#'`, y el código va tal cual, con sus propios comentarios. Abre `laboratorios.Rproj`, abre el guion y ejecuta línea a línea con `Ctrl+Enter` (`Cmd+Enter` en Mac). No necesita pandoc ni *Knit*.

### C · Solo leer (`html/`)
Cada laboratorio tiene su `.html` con todas las salidas ya calculadas. Se abre en cualquier navegador, también sin conexión.

### D · Google Colab (`google_colab/`)
Es opcional: a veces tarda en conectar el entorno de R.

| Lab | Qué se hace | Datos | Colab |
|---|---|---|---|
| 0 · Conexión | Qué es cada tabla, relaciones y una base DuckDB conectada | Servicios | [![Abrir en Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/vicentcorrecher/lab-limpieza-datos/blob/main/google_colab/lab0_conexion.ipynb) |
| 1 · Auditoría | Cuadro de calidad con semáforo | Servicios | [![Abrir en Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/vicentcorrecher/lab-limpieza-datos/blob/main/google_colab/lab1_auditoria.ipynb) |
| 2 · Depuración | Corregir, marcar o preguntar | Servicios | [![Abrir en Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/vicentcorrecher/lab-limpieza-datos/blob/main/google_colab/lab2_depuracion.ipynb) |
| 3 · Faltantes | ¿Imputar o no imputar? Experimento MCAR frente a MNAR | Servicios | [![Abrir en Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/vicentcorrecher/lab-limpieza-datos/blob/main/google_colab/lab3_faltantes.ipynb) |
| 4 · Impacto en KPIs | ¿Cambian los KPIs al limpiar? | Servicios | [![Abrir en Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/vicentcorrecher/lab-limpieza-datos/blob/main/google_colab/lab4_impacto_kpis.ipynb) |
| 5 · Dato sucio | Cuando el dato viene mal de verdad | Distribuidora | [![Abrir en Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/vicentcorrecher/lab-limpieza-datos/blob/main/google_colab/lab5_dato_sucio.ipynb) |

En Colab: *Entorno de ejecución → Cambiar tipo de entorno de ejecución → R*, y después *Ejecutar todo*.

## Requisitos y versiones probadas
- **R 4.3 o superior.** Los laboratorios usan el operador `|>` y la sintaxis `\(x)`, que no existen en versiones anteriores. Si tu R es más antiguo, el laboratorio se detiene en la primera celda y te lo dice.
- **Conexión a internet** solo la primera vez, para instalar paquetes. Los datos ya vienen en el ZIP y no se descarga nada si están en `datos/`.
- **Probado con** R 4.6.1 en Windows 11, con tidyverse 2.0.0 (dplyr 1.2.1, readr 2.2.0), DBI 1.3.0, duckdb 1.5.6, mice 3.19.0, rmarkdown 2.32 y knitr 1.52. Los seis laboratorios generan el informe completo en menos de 20 segundos cada uno, y los resultados son idénticos en cada ejecución: los experimentos con azar fijan la semilla y la fecha de corte del laboratorio 5 es fija.
- **Windows, macOS y Linux:** el mismo código funciona en los tres. En Linux se usan binarios precompilados de Posit Package Manager cuando la versión de Ubuntu los ofrece (22.04 y 24.04), y en cualquier otra se instala desde CRAN, más lento.
- **Para pulsar Knit** hace falta pandoc. RStudio lo incluye; con R a secas o VS Code, usa los guiones de `R/` o abre los `.html`.

## Si algo falla
| Síntoma | Causa y solución |
|---|---|
| `file name conversion problem -- name too long?` al hacer Knit | Tu usuario de Windows tiene tilde o eñe. Abre el proyecto con `laboratorios.Rproj` (carga el parche de `.Rprofile`) o mueve la carpeta a `C:\labs`. |
| `Estos laboratorios necesitan R 4.3 o superior` | Actualiza R desde [cran.r-project.org](https://cran.r-project.org/). |
| `there is no package called ...` o falla la instalación | Ejecuta `instalar_paquetes.R` con *Source* y mira el mensaje del paquete que falta. |
| No encuentra `datos/...` | Abre `laboratorios.Rproj` (o fija la carpeta del proyecto como directorio de trabajo) antes de ejecutar los guiones de `R/`. Los `.Rmd` ya buscan `datos/` en la carpeta del proyecto. |

## Contenido

```
laboratorios.Rproj · instalar_paquetes.R
rmarkdown/       lab0..lab5 .Rmd: los laboratorios para RStudio (fuente de todo lo demás)
R/               lab0..lab5 .R: guiones paso a paso, con el texto en comentarios
html/            lab0..lab5 .html: informes con la marca y todas las salidas
google_colab/    lab0..lab5 .ipynb: cuadernos para Colab (kernel R), generados desde los .Rmd
generar_material.R  regenera html/, R/ y google_colab/ a partir de rmarkdown/
assets/          marca.css, marca_pie.html y las fuentes Montserrat y DM Sans (licencia OFL) incrustadas en los .html
datos/
  servicios/    5 CSV de una empresa de servicios (2022-2025)
  distribuidora/    dataset sucio a propósito, con su «verdad» (gold standard)
  funciones_labs.R  funciones que usan los laboratorios 0-4
```

Si modificas un `.Rmd`, ejecuta `generar_material.R` para actualizar `html/`, `R/` y `google_colab/`: así los cuatro formatos dicen siempre lo mismo.

Los datos están generados de forma sintética: no representan a ninguna empresa ni persona real.
