# Instala (una sola vez) los paquetes que usan los laboratorios.
# En RStudio: abre este archivo y pulsa "Source" (o Ctrl+Shift+S).
# Si prefieres no hacerlo ahora, no pasa nada: la primera celda de cada laboratorio instala lo que falte.

if (getRversion() < "4.3.0")
  stop("Estos laboratorios necesitan R 4.3 o superior (tienes ", getRversion(), "). Actualiza desde https://cran.r-project.org/")

if (is.null(getOption("repos")) || isTRUE(unname(getOption("repos")["CRAN"]) == "@CRAN@"))
  options(repos = c(CRAN = "https://cloud.r-project.org"))

paquetes <- c("tidyverse", "DBI", "duckdb", "mice", "rmarkdown", "knitr")
faltan <- paquetes[!vapply(paquetes, requireNamespace, logical(1), quietly = TRUE)]

if (length(faltan)) {
  message("Instalando: ", paste(faltan, collapse = ", "), " (puede tardar unos minutos)")
  install.packages(faltan)
}

ok <- vapply(paquetes, requireNamespace, logical(1), quietly = TRUE)
print(ok)
if (all(ok)) {
  message("Todo listo. Abre lab0_conexion.Rmd")
  message("Versiones: R ", getRversion(), " · ", paste(paquetes, vapply(paquetes, function(p) as.character(packageVersion(p)), ""), collapse = " · "))
} else message("Faltan paquetes: ", paste(names(ok)[!ok], collapse = ", "))

# El botón "Knit" necesita pandoc. RStudio lo trae incluido; con R a secas no.
# Si no lo tienes, ejecuta celda a celda (funciona igual) o abre los .html ya generados.
tiene_pandoc <- tryCatch(rmarkdown::pandoc_available(), error = function(e) FALSE)
if (!tiene_pandoc) message("Aviso: no se encuentra pandoc, así que 'Knit' no funcionará. Instala RStudio o ejecuta celda a celda.")

# Aviso: si tu usuario de Windows tiene tildes o eñes (p. ej. C:/Users/Muñoz), guarda esta carpeta
# en una ruta sin tildes (p. ej. C:/labs) para que el botón "Knit" funcione sin problemas.
if (grepl("[^ -~]", getwd())) warning("La ruta de esta carpeta tiene caracteres especiales: si 'Knit' falla, muévela a C:/labs")
