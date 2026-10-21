# Regenera, a partir de rmarkdown/*.Rmd, los tres materiales derivados:
#   html/           informes con la marca y todas las salidas calculadas
#   R/              guiones para trabajar paso a paso: el texto del laboratorio pasa a comentarios
#   google_colab/   cuadernos para Colab (kernel R), con las mismas celdas que el .Rmd
# Ejecutar con la carpeta del proyecto como directorio de trabajo: abre laboratorios.Rproj y pulsa "Source".
# Cada laboratorio se ejecuta en un entorno limpio, igual que lo haría una persona desde cero.
labs <- sprintf("lab%s", c("0_conexion", "1_auditoria", "2_depuracion", "3_faltantes", "4_impacto_kpis", "5_dato_sucio"))
dir.create("html", showWarnings = FALSE)
dir.create("R", showWarnings = FALSE)
dir.create("google_colab", showWarnings = FALSE)

# En Colab no existe la carpeta del proyecto: antes de preparar el entorno se descarga el preparador
paso_colab <- c(
  "# En Colab no hay carpeta del proyecto: bajamos primero el preparador (después él hace todo lo demás)",
  'dir.create("datos", showWarnings = FALSE)',
  'download.file("https://raw.githubusercontent.com/vicentcorrecher/lab-limpieza-datos/main/datos/preparar_entorno.R", "datos/preparar_entorno.R", quiet = TRUE, mode = "wb")',
  'source("datos/preparar_entorno.R")')

# .Rmd -> .ipynb: el texto pasa a celdas de Markdown y cada bloque de código a una celda de código
rmd_a_ipynb <- function(rmd, salida) {
  x <- readLines(rmd, encoding = "UTF-8")
  fin_yaml <- which(x == "---")[2]
  cab <- x[2:(fin_yaml - 1)]
  titulo <- sub('^title: "(.*)"$', "\\1", grep("^title:", cab, value = TRUE))
  subtitulo <- sub('^subtitle: "(.*)"$', "\\1", grep("^subtitle:", cab, value = TRUE))
  x <- x[-seq_len(fin_yaml)]

  celda <- function(tipo, lineas) {
    while (length(lineas) && !nzchar(trimws(lineas[1]))) lineas <- lineas[-1]
    while (length(lineas) && !nzchar(trimws(lineas[length(lineas)]))) lineas <- lineas[-length(lineas)]
    if (!length(lineas)) return(NULL)
    fuente <- as.list(paste0(lineas, c(rep("\n", length(lineas) - 1), "")))
    vacio <- setNames(list(), character(0))
    if (tipo == "markdown") list(cell_type = "markdown", metadata = vacio, source = fuente)
    else list(cell_type = "code", metadata = vacio, execution_count = NA, outputs = list(), source = fuente)
  }

  celdas <- list(celda("markdown", c(paste("#", titulo), "", paste0("*", subtitulo, "*"))))
  prosa <- character()
  i <- 1
  while (i <= length(x)) {
    if (grepl("^```\\{r", x[i])) {
      celdas <- c(celdas, list(celda("markdown", prosa)))
      prosa <- character()
      j <- i + 1
      while (x[j] != "```") j <- j + 1
      if (!grepl("purl *= *FALSE", x[i])) {
        codigo <- x[(i + 1):(j - 1)]
        codigo <- unlist(lapply(codigo, function(l) if (l == 'source("datos/preparar_entorno.R")') paso_colab else l))
        celdas <- c(celdas, list(celda("code", codigo)))
      }
      i <- j + 1
    } else {
      prosa <- c(prosa, x[i])
      i <- i + 1
    }
  }
  celdas <- c(celdas, list(celda("markdown", prosa)))
  celdas <- Filter(Negate(is.null), celdas)

  cuaderno <- list(
    cells = celdas,
    metadata = list(kernelspec = list(display_name = "R", language = "R", name = "ir"),
                    language_info = list(name = "R", file_extension = ".r", mimetype = "text/x-r-source")),
    nbformat = 4L, nbformat_minor = 4L)
  jsonlite::write_json(cuaderno, salida, auto_unbox = TRUE, pretty = TRUE, na = "null", null = "null")
}

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

  # Cuaderno de Colab
  rmd_a_ipynb(rmd, file.path("google_colab", paste0(l, ".ipynb")))
}
message("Listo: ", length(labs), " informes en html/, ", length(labs), " guiones en R/ y ", length(labs), " cuadernos en google_colab/.")
