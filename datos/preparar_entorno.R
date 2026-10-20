# Prepara el entorno de los laboratorios. Cada laboratorio lo llama con dos líneas; no hace falta leerlo.
#   1. Comprueba que R es lo bastante reciente.
#   2. Instala los paquetes que falten (solo la primera vez).
#   3. Carga los paquetes y las funciones de los laboratorios.
#   4. Descarga los datos si no están en la carpeta datos/.

preparar <- function(datos = c("servicios", "distribuidora"), paquetes = "tidyverse") {
  datos <- match.arg(datos)

  if (getRversion() < "4.3.0")
    stop("Estos laboratorios necesitan R 4.3 o superior (tienes ", getRversion(), "). Actualiza desde https://cran.r-project.org/")

  # De dónde se instalan los paquetes
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

  # Instalar solo lo que falte
  faltan <- paquetes[!vapply(paquetes, requireNamespace, logical(1), quietly = TRUE)]
  if (length(faltan)) install.packages(faltan)

  # Cargar los paquetes que los laboratorios usan sin escribir el prefijo (mice y duckdb se usan con ::)
  for (p in intersect(paquetes, c("tidyverse", "DBI")))
    suppressPackageStartupMessages(library(p, character.only = TRUE))

  # Los datos: si no están en la carpeta, se descargan
  base_url <- "https://raw.githubusercontent.com/vicentcorrecher/lab-limpieza-datos/main/datos"
  ficheros <- switch(datos,
    servicios = c("funciones_labs.R", paste0("servicios/", c("operaciones", "clientes", "productos_servicios", "sedes", "campanas"), ".csv")),
    distribuidora = paste0("distribuidora/", c("clientes_sucio", "ventas_sucio", "registro_mercantil", "clientes_gold"), ".csv"))
  for (f in ficheros) {
    ruta <- file.path("datos", f)
    if (!file.exists(ruta)) {
      dir.create(dirname(ruta), recursive = TRUE, showWarnings = FALSE)
      download.file(paste0(base_url, "/", f), ruta, quiet = TRUE, mode = "wb")
    }
  }
  if (datos == "servicios") source("datos/funciones_labs.R")
  invisible(TRUE)
}
