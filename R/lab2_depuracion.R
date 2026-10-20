# Lab 2 · Depuración: cada decisión tiene un coste
# Guion para ir paso a paso: abre laboratorios.Rproj y ejecuta línea a línea con Ctrl+Enter (Cmd+Enter en Mac).
# El texto del laboratorio está en los comentarios que empiezan por #'. Lo mismo, con salidas, en html/.

#' > **Objetivo.** Ver cómo se resuelve cada problema que detectó la auditoría **y quién decide** qué se hace con él. Fíjate en que algunas cosas se **corrigen**, otras solo se **marcan** y otras solo se **preguntan**.
#'
# ── Preparación (ejecutar una vez) ───────────────────────────────────────────
# Funciona en cualquier máquina con R: instala lo que falte y descarga los datos si no están.
if (getRversion() < "4.3.0")
  stop("Estos laboratorios necesitan R 4.3 o superior (tienes ", getRversion(), "). Actualiza desde https://cran.r-project.org/")
if (is.null(getOption("repos")) || isTRUE(unname(getOption("repos")["CRAN"]) == "@CRAN@"))
  options(repos = c(CRAN = "https://cloud.r-project.org"))
# En Linux (Colab, Codespaces) usamos binarios precompilados: se instalan en segundos.
# Solo para las versiones de Ubuntu que los publican; en cualquier otra se instala desde CRAN.
if (Sys.info()[["sysname"]] == "Linux") {
  cod <- tryCatch(sub("^VERSION_CODENAME=", "", grep("^VERSION_CODENAME=", readLines("/etc/os-release"), value = TRUE)[1]),
                  error = function(e) NA_character_)
  if (cod %in% c("jammy", "noble"))
    options(repos = c(CRAN = paste0("https://packagemanager.posit.co/cran/__linux__/", cod, "/latest")))
}

paquetes <- c("tidyverse")
faltan <- paquetes[!vapply(paquetes, requireNamespace, logical(1), quietly = TRUE)]
if (length(faltan)) install.packages(faltan)
suppressPackageStartupMessages({
library(tidyverse)
})

# Los datos: si no están en la carpeta, se descargan
BASE_URL <- "https://raw.githubusercontent.com/vicentcorrecher/lab-limpieza-datos/main/datos"
obtener <- function(f) {
  ruta <- file.path("datos", f)
  if (!file.exists(ruta)) {
    dir.create(dirname(ruta), recursive = TRUE, showWarnings = FALSE)
    download.file(paste0(BASE_URL, "/", f), ruta, quiet = TRUE, mode = "wb")
  }
}
for (f in c(
  "funciones_labs.R",
  "servicios/operaciones.csv",
  "servicios/clientes.csv",
  "servicios/productos_servicios.csv",
  "servicios/sedes.csv",
  "servicios/campanas.csv"
)) obtener(f)
source("datos/funciones_labs.R")

d <- cargar_servicios()
o <- d$operaciones

#' ## 1. Duplicados: lo evidente
#'
dup <- o |> filter(duplicated(operacion_id) | duplicated(operacion_id, fromLast = TRUE)) |> arrange(operacion_id)
dup |> select(operacion_id, fecha, cliente_id, canal, ingresos, satisfaccion) |> head(8)

cat("Filas duplicadas:", nrow(o) - nrow(distinct(o)), "\n")
cat("Ingresos que se contarían de más:", round(sum(o$ingresos) - sum(distinct(o)$ingresos), 2), "€\n")

#' **Decisión: eliminar.** Es la misma fila entera dos veces; no hay duda razonable.
#'
#' ## 2. Categorías: lo que se arregla con una regla
#'
d$clientes |> count(canal_alta, sort = TRUE)

d$clientes |> mutate(canal_alta = str_to_lower(str_squish(canal_alta))) |> count(canal_alta, sort = TRUE)

#' **Decisión: normalizar** (minúsculas, sin espacios sobrantes). Ojo: esto solo sirve porque *sabemos* que «Web » y «web» son lo mismo.
#'
#' ## 3. Operaciones anteriores al alta del cliente: un problema que no es del dato
#'
oc <- o |>
  left_join(select(d$clientes, cliente_id, fecha_alta), by = "cliente_id") |>
  mutate(dias_antes = as.numeric(fecha_alta - fecha))

oc |>
  group_by(anyo_de_alta = year(fecha_alta)) |>
  summarise(operaciones = n(), anteriores_al_alta = sum(dias_antes > 0), pct = round(100 * mean(dias_antes > 0), 1))

oc |> filter(dias_antes > 0) |>
  ggplot(aes(dias_antes)) +
  geom_histogram(bins = 40, fill = "#11D0CA") +
  labs(title = "¿Cuántos días antes del alta ocurre la operación?", x = "días entre la operación y el alta del cliente", y = "operaciones") +
  theme_marca(base_size = 13)

#' Solo afecta a clientes dados de alta en 2022-2023, justo cuando empieza el periodo de operaciones. Hipótesis posibles:
#'
#' 1. `fecha_alta` es la fecha de registro en el CRM, no la de su primera compra (clientes migrados).
#' 2. Error al introducir el alta.
#' 3. Las operaciones se imputan a clientes que luego se registran (venta sin registro).
#'
#' **Decisión: marcar, no borrar.** Con los datos no podemos distinguir entre estas hipótesis; hay que preguntarlo a quien conoce el proceso.
#'
#' ## 4. Margen negativo: ¿error o decisión comercial?
#'
o |>
  mutate(tramo_dto = cut(descuento_pct, c(-Inf, .1, .2, .3, .4, Inf), labels = c("<10%", "10-20%", "20-30%", "30-40%", ">40%"))) |>
  group_by(tramo_dto) |>
  summarise(operaciones = n(), pct_con_margen_negativo = round(100 * mean(margen < 0), 1)) |>
  ggplot(aes(tramo_dto, pct_con_margen_negativo)) +
  geom_col(fill = "#F2B84B") +
  labs(title = "% de operaciones con margen negativo según el descuento aplicado", x = "descuento", y = "% con margen negativo") +
  theme_marca(base_size = 13)

#' El margen negativo **solo aparece con descuentos altos**. Eso no huele a error de tecleo: huele a política de descuentos.
#'
#' **Decisión: marcar y avisar a negocio.** Eliminarlas escondería justo lo que a dirección le interesa ver.
#'
#' ## 5. Valores extremos en `duracion_min` (variable propia del sector Servicios)
#'
lim_iqr <- \(x, k) quantile(x, .75) + k * IQR(x)

o |> left_join(d$productos |> select(producto_id, categoria), by = "producto_id") |>
  group_by(categoria) |>
  summarise(mediana = median(duracion_min), p99 = quantile(duracion_min, .99), maximo = max(duracion_min),
            atipicas_k15 = sum(duracion_min > lim_iqr(duracion_min, 1.5)),
            atipicas_k3  = sum(duracion_min > lim_iqr(duracion_min, 3)),
            atipicas_k5  = sum(duracion_min > lim_iqr(duracion_min, 5)))

#' La regla «Q3 + k·IQR» marca como atípico lo que se aleja del grueso. **El umbral `k` lo elige quien analiza**: con 1,5 marca muchos valores; con 5, casi ninguno.
#'
o |> ggplot(aes(duracion_min)) +
  geom_histogram(bins = 60, fill = "#11D0CA") +
  geom_vline(xintercept = quantile(o$duracion_min, .75) + 3 * IQR(o$duracion_min), colour = "#F26B5B", linetype = "dashed") +
  labs(title = "Distribución de la duración del servicio", subtitle = "línea roja: Q3 + 3·IQR", x = "minutos", y = "operaciones") +
  theme_marca(base_size = 13)

#' **Decisión: marcar.** Un servicio de 7 horas puede ser un error o un proyecto grande.
#'
#' ## 6. Lo que has visto, en una sola función
#'
#' Toda la limpieza anterior vive en `limpiar_servicios()` (puedes abrir `datos/funciones_labs.R` y leerla). Cada decisión es un **argumento**: por defecto **solo se marcan** los problemas y se eliminan los duplicados exactos.
#'
# >>> TOCA AQUÍ: elige qué problemas se convierten en filas eliminadas <<<
# opciones: "antes_alta", "antes_lanzamiento", "margen_negativo", "sector"
EXCLUIR <- c()          # prueba, por ejemplo: c("antes_alta")   o   c("margen_negativo", "sector")
K_IQR   <- 3            # prueba 1.5 o 5

l <- limpiar_servicios(d, excluir = EXCLUIR, k_iqr = K_IQR)
l$log

cat("Filas de operaciones: ", nrow(d$operaciones), "(originales) ->", nrow(l$operaciones), "(tras tus decisiones)\n")

#' > ### Para pensar
#' > 1. De los cinco problemas, ¿cuáles **corriges**, cuáles **marcas** y cuáles **preguntas**? ¿Qué criterio has usado?
#' > 2. Excluye `"antes_alta"` y mira cuántas filas desaparecen. ¿Te parece razonable descartar tanto dato por una fecha de alta?
#' > 3. Hay 1.346 operaciones anteriores al **lanzamiento del servicio** (`"antes_lanzamiento"`). ¿Qué dato está mal, la operación o la fecha de lanzamiento?
#' > 4. El «diario» (`l$log`) lista las decisiones. ¿Por qué es importante que **quede escrito** y no solo hecho?
