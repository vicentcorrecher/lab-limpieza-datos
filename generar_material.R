# Regenera, a partir de rmarkdown/*.Rmd, los dos materiales derivados:
#   html/  informes con la marca y todas las salidas calculadas
#   R/     guiones para trabajar paso a paso: el texto del laboratorio pasa a comentarios
# Ejecutar con la carpeta del proyecto como directorio de trabajo: abre laboratorios.Rproj y pulsa "Source".
# Cada laboratorio se ejecuta en un entorno limpio, igual que lo haría una persona desde cero.
labs <- sprintf("lab%s", c("0_conexion", "1_auditoria", "2_depuracion", "3_faltantes", "4_impacto_kpis", "5_dato_sucio"))
dir.create("html", showWarnings = FALSE)
dir.create("R", showWarnings = FALSE)

for (l in labs) {
  message("Generando ", l, " ...")
  rmd <- file.path("rmarkdown", paste0(l, ".Rmd"))
  rmarkdown::render(rmd, output_dir = "html", envir = new.env(), quiet = TRUE)

  # Guion R: el texto en Markdown queda como comentarios «#'» y el código tal cual
  out <- file.path("R", paste0(l, ".R"))
  knitr::purl(rmd, output = out, documentation = 2, quiet = TRUE, encoding = "UTF-8")
  x <- readLines(out, encoding = "UTF-8")
  titulo <- sub("^#' title: \"(.*)\"$", "\\1", grep("^#' title: ", x, value = TRUE)[1])
  fin_yaml <- which(x == "#' ---")[2]
  x <- sub("[ ]+$", "", x[-seq_len(fin_yaml)])      # fuera la cabecera YAML y los espacios finales
  x <- x[!grepl("^## -{4}.*-{4}$", x)]             # fuera las marcas «## ---- chunk ----» de knitr
  vacia <- x %in% c("", "#'")
  x <- x[!(vacia & c(TRUE, head(vacia, -1)))]      # una sola línea en blanco seguida, ninguna al principio
  cabecera <- c(paste0("# ", titulo),
                "# Guion para ir paso a paso: abre laboratorios.Rproj y ejecuta línea a línea con Ctrl+Enter (Cmd+Enter en Mac).",
                "# El texto del laboratorio está en los comentarios que empiezan por #'. Lo mismo, con salidas, en html/.",
                "")
  writeLines(c(cabecera, x), out, useBytes = TRUE)
}
message("Listo: ", length(labs), " informes en html/ y ", length(labs), " guiones en R/.")
