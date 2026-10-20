# Lab 0 · Conexión: ¿qué tengo entre manos?
# Guion para ir paso a paso: abre laboratorios.Rproj y ejecuta línea a línea con Ctrl+Enter (Cmd+Enter en Mac).
# El texto del laboratorio está en los comentarios que empiezan por #'. Lo mismo, con salidas, en html/.

#' > **Cómo funciona este laboratorio.** No tienes que escribir código: está todo hecho. Tu trabajo es **leer lo que sale, cuestionarlo y proponer qué cambiarías**. Ejecuta cada celda con ▶ (o *Entorno de ejecución → Ejecutar todo*) y para las preguntas de **Para pensar** habla con tu compañero/a antes de seguir.
#'
#' ## 1. Preparar el entorno
#'
#' La primera vez tarda un poco (instala paquetes y descarga los datos). Las siguientes ya es inmediato.
#'
# ── Preparación (ejecutar una vez) ───────────────────────────────────────────
# Instala lo que falte, carga los paquetes y descarga los datos si no están (la primera vez tarda unos minutos).
source("datos/preparar_entorno.R")
preparar(datos = "servicios", paquetes = c("tidyverse", "DBI", "duckdb"))

#' ## 2. Los cinco ficheros del caso
#'
#' Es una empresa **de servicios** ficticia, con operaciones entre 2022 y 2025. La guía común dice que `operaciones` es la tabla central y que las demás la describen. Vamos a comprobarlo, no a creérnoslo.
#'
d <- cargar_servicios()

resumen <- tibble(
  tabla    = names(d),
  filas    = map_int(d, nrow),
  columnas = map_int(d, ncol),
  que_es_una_fila = c("una operación (un servicio prestado)", "un cliente", "un servicio del catálogo", "una sede", "una acción comercial")
)
resumen

# Las primeras filas de la tabla central: míralas con calma
head(d$operaciones, 5)

#' > ### Para pensar
#' > 1. ¿Cuál es la **clave** de cada tabla (la columna que identifica una fila sin ambigüedad)?
#' > 2. ¿Por qué `operaciones` tiene casi 19.000 filas y `campanas` solo 24? ¿Qué te dice eso de qué es cada cosa?
#' > 3. ¿Qué columnas de `operaciones` son **medidas** (se pueden sumar) y cuáles son **códigos de enlace** (no se suman nunca)?
#'
#' ## 3. Una base de datos ya conectada
#'
#' En una empresa real los datos no están en CSV sueltos: viven en una base de datos (Snowflake, SQL Server, PostgreSQL...). Aquí simulamos esa situación con **DuckDB**, una base de datos que funciona dentro del propio cuaderno.
#'
con <- dbConnect(duckdb::duckdb())                  # abrimos la conexión
iwalk(d, \(tabla, nombre) dbWriteTable(con, nombre, tabla))   # cargamos las 5 tablas
dbListTables(con)

#' Ahora podemos hacerle preguntas **en SQL**, igual que harías en el trabajo:
#'
consulta <- "
SELECT s.nombre AS sede,
       s.provincia,
       COUNT(*)               AS operaciones,
       ROUND(SUM(o.ingresos)) AS ingresos,
       ROUND(SUM(o.margen))   AS margen
FROM operaciones o
JOIN sedes s USING (sede_id)
GROUP BY 1, 2
ORDER BY ingresos DESC
"
por_sede <- dbGetQuery(con, consulta)
por_sede

#' Y la misma pregunta con `dplyr`. Si todo está bien, **tiene que dar lo mismo**:
#'
por_sede_dplyr <- d$operaciones |>
  inner_join(d$sedes, by = "sede_id") |>
  group_by(sede = nombre, provincia) |>
  summarise(operaciones = n(), ingresos = round(sum(ingresos)), margen = round(sum(margen)), .groups = "drop") |>
  arrange(desc(ingresos))

all.equal(as.data.frame(por_sede), as.data.frame(por_sede_dplyr), check.attributes = FALSE)

#' ## 4. El mapa de relaciones
#'
#' ```
#'         clientes ─────┐
#'    (cliente_id)       │ 1
#'                       ▼ N
#' productos_servicios ─▶ OPERACIONES ◀───── sedes
#'    (producto_id)  1  N  (operacion_id)  N  1  (sede_id)
#'
#' campanas  (sin enlace directo: solo se puede cruzar por fechas, canal o segmento)
#' ```
#'
#' > ### Para pensar
#' > 1. La guía avisa: *«una coincidencia temporal no demuestra que una campaña haya causado un resultado»*. ¿Por qué no podemos unir `campanas` a `operaciones` con un `JOIN`?
#' > 2. Si dos sedes comparten nombre de provincia, ¿el `JOIN` por `sede_id` las mezcla? ¿Y si las uniéramos por `provincia`?
#'
#' ### Toca esto
#'
#' Cambia la consulta SQL de arriba para agrupar **por categoría de servicio** (necesitas unir con `productos`) en lugar de por sede. No hace falta que la escribas: dime en voz alta qué tabla unirías y por qué columna.
#'
dbDisconnect(con, shutdown = TRUE)

