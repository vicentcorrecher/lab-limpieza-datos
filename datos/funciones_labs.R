# Funciones compartidas por los laboratorios (empresa de servicios multisede).
# El alumnado NO tiene que escribir nada de esto: se carga con source() y se lee.

suppressPackageStartupMessages({ library(dplyr); library(readr); library(stringr); library(tidyr) })

# ---- 1. Carga: identificadores como texto (como pide la guía), fechas como fecha --------
cargar_servicios <- function(dir = "datos/servicios") {
  # Los *_id llevan letras (O0000001, C00470...), así que readr los lee como texto.
  rd <- function(f) read_csv(file.path(dir, f), show_col_types = FALSE)
  list(operaciones = rd("operaciones.csv"), clientes = rd("clientes.csv"),
       productos = rd("productos_servicios.csv"), sedes = rd("sedes.csv"), campanas = rd("campanas.csv"))
}

# ---- 2. Limpieza parametrizada: cada decisión es un argumento --------------------------
# excluir: qué banderas se convierten en filas eliminadas. Por defecto NINGUNA (solo se marca).
limpiar_servicios <- function(d, excluir = character(), k_iqr = 3, col_sector = "duracion_min") {
  log <- tibble(regla = character(), filas_afectadas = integer(), decision = character())
  anota <- function(regla, n, decision) log <<- bind_rows(log, tibble(regla = regla, filas_afectadas = as.integer(n), decision = decision))

  # (a) categorías: «Web » -> «web»
  cli <- d$clientes |> mutate(canal_alta_orig = canal_alta, canal_alta = str_to_lower(str_squish(canal_alta)))
  anota("canal_alta con mayúsculas/espacios", sum(cli$canal_alta != cli$canal_alta_orig), "normalizar (minúsculas, sin espacios)")

  # (b) duplicados exactos
  ops <- d$operaciones
  n0 <- nrow(ops)
  ops <- distinct(ops)
  anota("filas duplicadas (operacion_id repetido)", n0 - nrow(ops), "eliminar")

  # (c) banderas (no borran nada por sí solas)
  ops <- ops |>
    left_join(select(cli, cliente_id, fecha_alta), by = "cliente_id", relationship = "many-to-one") |>
    left_join(select(d$productos, producto_id, categoria, fecha_lanzamiento), by = "producto_id", relationship = "many-to-one") |>
    mutate(f_antes_alta = fecha < fecha_alta,
           f_antes_lanzamiento = fecha < fecha_lanzamiento,
           f_margen_negativo = margen < 0)
  anota("operación anterior al alta del cliente", sum(ops$f_antes_alta), "marcar")
  anota("operación anterior al lanzamiento del producto", sum(ops$f_antes_lanzamiento), "marcar")
  anota("margen negativo (coste > ingresos)", sum(ops$f_margen_negativo), "marcar")

  if (col_sector %in% names(ops)) {
    ops <- ops |> group_by(categoria) |>
      mutate(.lim = quantile(.data[[col_sector]], .75) + k_iqr * IQR(.data[[col_sector]]),
             f_sector_atipico = .data[[col_sector]] > .lim) |>
      ungroup() |> select(-.lim)
    anota(paste0(col_sector, " atípica (Q3 + ", k_iqr, "·IQR por categoría)"), sum(ops$f_sector_atipico), "marcar")
  } else ops$f_sector_atipico <- FALSE

  # (d) política de exclusión: elegida por quien analiza, no por el código
  mapa <- c(antes_alta = "f_antes_alta", antes_lanzamiento = "f_antes_lanzamiento",
            margen_negativo = "f_margen_negativo", sector = "f_sector_atipico")
  quitar <- Reduce(`|`, lapply(mapa[excluir], function(f) ops[[f]]), init = rep(FALSE, nrow(ops)))
  anota(paste("exclusión elegida:", if (length(excluir)) paste(excluir, collapse = " + ") else "ninguna"), sum(quitar), "eliminar de los KPIs")
  ops <- ops[!quitar, ]

  list(operaciones = ops, clientes = select(cli, -canal_alta_orig), productos = d$productos,
       sedes = d$sedes, campanas = d$campanas, log = log)
}

# ---- 3. KPIs --------------------------------------------------------------------------
kpis <- function(ops) {
  tibble(operaciones = nrow(ops),
         ingresos = sum(ops$ingresos),
         margen = sum(ops$margen),
         margen_pct = 100 * sum(ops$margen) / sum(ops$ingresos),
         ticket_medio = mean(ops$ingresos),
         satisfaccion_media = mean(ops$satisfaccion, na.rm = TRUE),
         tasa_incidencia = 100 * mean(ops$incidencia),
         pct_margen_negativo = 100 * mean(ops$margen < 0))
}

# ---- 4. Marca: tema de los gráficos (colores de la presentación) ----------------------
theme_marca <- function(base_size = 13) {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      text = ggplot2::element_text(colour = "#1D324D"),
      axis.text = ggplot2::element_text(colour = "#5B6F86"),
      plot.title = ggplot2::element_text(face = "bold", colour = "#1D324D"),
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_line(colour = "#E3EBF1"),
      legend.position = "top"
    )
}
