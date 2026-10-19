# Instala (una sola vez) los paquetes que usan los laboratorios.
# En RStudio: abre este archivo y pulsa "Source" (o Ctrl+Shift+S).
# Si prefieres no hacerlo ahora, no pasa nada: la primera celda de cada laboratorio instala lo que falte.

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
if (all(ok)) message("Todo listo. Abre lab0_conexion.Rmd") else message("Faltan paquetes: ", paste(names(ok)[!ok], collapse = ", "))

# Aviso: si tu usuario de Windows tiene tildes o eñes (p. ej. C:/Users/Muñoz), guarda esta carpeta
# en una ruta sin tildes (p. ej. C:/labs) para que el botón "Knit" funcione sin problemas.
if (grepl("[^ -~]", getwd())) warning("La ruta de esta carpeta tiene caracteres especiales: si 'Knit' falla, muévela a C:/labs")
