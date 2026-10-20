# Lab 4 · Impacto: ¿cambian tus KPIs al limpiar?
# Guion para ir paso a paso: abre laboratorios.Rproj y ejecuta línea a línea con Ctrl+Enter (Cmd+Enter en Mac).
# El texto del laboratorio está en los comentarios que empiezan por #'. Lo mismo, con salidas, en html/.

#' > **Objetivo.** Limpiar no es un fin: sirve para que **las cifras que das sean defendibles**. Calculamos los mismos KPIs con cuatro niveles de limpieza y comprobamos cuánto se mueve cada uno. Es el «tres personas, tres cifras» de la parte de gobierno, pero con datos de verdad.
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
  "estudiante_18/operaciones.csv",
  "estudiante_18/clientes.csv",
  "estudiante_18/productos_servicios.csv",
  "estudiante_18/sedes.csv",
  "estudiante_18/campanas.csv"
)) obtener(f)
source("datos/funciones_labs.R")

d <- cargar_e18()

#' ## 1. Cuatro escenarios
#'
#' | Escenario | Qué hace |
#' |---|---|
#' | **A · Bruto** | Los datos tal cual llegan, sin tocar nada |
#' | **B · Prudente** | Quita duplicados exactos. Marca el resto de problemas, **sin excluir nada** |
#' | **C · Sin operaciones anteriores al alta** | B + descarta las operaciones anteriores al alta del cliente |
#' | **D · Estricto** | C + descarta márgenes negativos y duraciones atípicas |
#'
escenarios <- list(
  "A · Bruto"       = d$operaciones,
  "B · Prudente"    = limpiar_e18(d)$operaciones,
  "C · Sin pre-alta" = limpiar_e18(d, excluir = "antes_alta")$operaciones,
  "D · Estricto"    = limpiar_e18(d, excluir = c("antes_alta", "margen_negativo", "sector"))$operaciones)

tabla <- imap_dfr(escenarios, \(ops, nombre) kpis(ops) |> mutate(escenario = nombre, .before = 1))
tabla |> mutate(across(where(is.numeric), \(x) round(x, 2)))

#' ## 2. ¿Cuánto se mueve cada KPI respecto al dato bruto?
#'
variacion <- tabla |>
  pivot_longer(-escenario, names_to = "kpi", values_to = "valor") |>
  group_by(kpi) |>
  mutate(variacion_pct = round(100 * (valor / valor[escenario == "A · Bruto"] - 1), 2)) |>
  ungroup()

variacion |> select(-valor) |> pivot_wider(names_from = escenario, values_from = variacion_pct)

variacion |>
  filter(kpi %in% c("operaciones", "ingresos", "margen", "margen_pct", "ticket_medio", "satisfaccion_media", "tasa_incidencia"),
         escenario != "A · Bruto") |>
  ggplot(aes(kpi, variacion_pct, fill = escenario)) +
  geom_col(position = "dodge") +
  geom_hline(yintercept = 0) +
  coord_flip() +
  scale_fill_manual(values = c("B · Prudente" = "#6CD7D9", "C · Sin pre-alta" = "#11D0CA", "D · Estricto" = "#F2B84B")) +
  labs(title = "Variación de cada KPI frente al dato bruto (%)", x = NULL, y = "% de variación", fill = NULL) +
  theme_marca(base_size = 13)

#' > ### Para pensar
#' > 1. ¿Qué KPIs **casi no se mueven** y cuáles **se mueven mucho**? ¿Por qué los KPIs que son *medias o ratios* aguantan mejor que los que son *sumas*?
#' > 2. Si el director pregunta «¿cuánto hemos ingresado?», ¿qué escenario le das? ¿Y si pregunta «¿cuál es nuestro margen?».
#' > 3. La decisión que más mueve las cifras (descartar operaciones anteriores al alta) es justo la que **no sabemos si es un error**. ¿Qué haces?
#'
#' ## 3. ¿Cambia el ranking de sedes?
#'
ranking <- imap_dfr(escenarios, \(ops, nombre) ops |>
  group_by(sede_id) |> summarise(ingresos = sum(ingresos), .groups = "drop") |>
  mutate(posicion = rank(-ingresos), escenario = nombre)) |>
  select(escenario, sede_id, posicion) |>
  pivot_wider(names_from = escenario, values_from = posicion) |>
  arrange(`A · Bruto`)
ranking

#' > Si el ranking de sedes **no cambia** entre escenarios, la decisión de limpieza no afecta a *«qué sede es la mejor»*, aunque sí a *«cuánto hemos ingresado»*. Las preguntas de negocio se ven afectadas de forma distinta.
#'
#' ## 4. Definir el KPI por escrito (la parte que de verdad evita discusiones)
#'
#' Esta tabla es lo que entregarías junto al cuadro de mando. **Mismo dato, pero cada cifra con su definición y su supuesto**:
#'
tribble(
  ~kpi, ~definicion, ~supuestos_documentados,
  "Ingresos", "Suma de `ingresos` de operaciones únicas", "Se eliminan 8 duplicados exactos; no se excluyen operaciones anteriores al alta",
  "Margen %", "Margen total / ingresos totales (no la media de porcentajes)", "Incluye operaciones con margen negativo (descuentos > 20 %)",
  "Satisfacción media", "Media de respuestas disponibles (1-10)", "Se ignoran 152 vacías (0,8 %), compatibles con ausencia al azar; se informa de n",
  "Tasa de incidencia", "% de operaciones con `incidencia = TRUE`", "Sin supuestos adicionales"
)

#' ### Toca esto
#'
#' Define **tu propio escenario**: elige qué excluir y compara con B.
#'
# >>> TOCA AQUÍ: opciones "antes_alta", "antes_lanzamiento", "margen_negativo", "sector" <<<
MI_ESCENARIO <- c("antes_lanzamiento")

bind_rows(
  kpis(escenarios[["B · Prudente"]]) |> mutate(escenario = "B · Prudente", .before = 1),
  kpis(limpiar_e18(d, excluir = MI_ESCENARIO)$operaciones) |> mutate(escenario = paste("Mi escenario:", paste(MI_ESCENARIO, collapse = " + ")), .before = 1)) |>
  mutate(across(where(is.numeric), \(x) round(x, 2)))

#' > ### Para pensar (cierre)
#' > **Tres analistas parten del mismo fichero y entregan tres cifras de ingresos distintas.** ¿Quién tiene razón? ¿Qué habría que acordar **antes** de calcular nada?
