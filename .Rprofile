# Parche para Windows cuando el nombre de usuario lleva tildes o eñes (p. ej. C:/Users/Muñoz).
# Sin él, el botón "Knit" puede fallar con: "file name conversion problem -- name too long?".
# Se ejecuta solo al abrir laboratorios.Rproj y no cambia nada si no hace falta.
if (.Platform$OS.type == "windows") {
  .parche_pandoc <- function() {
    p <- Sys.getenv("RSTUDIO_PANDOC")
    if (nzchar(p) && dir.exists(p) && requireNamespace("rmarkdown", quietly = TRUE))
      try(rmarkdown::find_pandoc(dir = p), silent = TRUE)
    invisible()
  }
  .parche_pandoc()
  setHook("rstudio.sessionInit", function(newSession) .parche_pandoc(), action = "append")
}
