# Lab 1 · Auditoría: ¿qué tan fiable es lo que tengo?
# Guion para ir paso a paso: abre laboratorios.Rproj y ejecuta línea a línea con Ctrl+Enter (Cmd+Enter en Mac).
# El texto del laboratorio está en los comentarios que empiezan por #'. Lo mismo, con salidas, en html/.

#' > **Objetivo.** Antes de limpiar nada, **medir**. Pasamos los cinco ficheros por las dimensiones de calidad de la teoría (completitud, unicidad, validez, consistencia) y obtenemos un **cuadro de calidad** con semáforo. Tu trabajo: leerlo y decidir qué importa.
#'
# ── Preparación (ejecutar una vez) ───────────────────────────────────────────
# Instala lo que falte, carga los paquetes y descarga los datos si no están (la primera vez tarda unos minutos).
source("datos/preparar_entorno.R")
preparar(datos = "servicios", paquetes = "tidyverse")

d <- cargar_servicios()   # una lista con las cinco tablas
o <- d$operaciones        # la tabla central, para escribir menos

#' Cada comprobación que hacemos es **una pregunta con respuesta en números**: cuántas filas incumplen una regla. Las iremos guardando en tablas con las mismas cuatro columnas (`dimension`, `comprobacion`, `incumplen`, `base`) para juntarlas al final.
#'
#' ## 1. Completitud: ¿falta algo?
#'
#' En R, un dato que falta se llama `NA`. Primero miramos **en qué columnas** de `operaciones` faltan datos:
#'
colSums(is.na(o))

#' Ahora contamos, en cada tabla, **cuántas filas tienen algún dato vacío**:
#'
completitud <- tribble(
  ~dimension,    ~comprobacion,                       ~incumplen,                        ~base,
  "Completitud", "operaciones con algún dato vacío",  sum(!complete.cases(o)),           nrow(o),
  "Completitud", "clientes con algún dato vacío",     sum(!complete.cases(d$clientes)),  nrow(d$clientes),
  "Completitud", "productos con algún dato vacío",    sum(!complete.cases(d$productos)), nrow(d$productos),
  "Completitud", "sedes con algún dato vacío",        sum(!complete.cases(d$sedes)),     nrow(d$sedes),
  "Completitud", "campañas con algún dato vacío",     sum(!complete.cases(d$campanas)),  nrow(d$campanas))
completitud

#' ## 2. Unicidad: ¿cada cosa aparece una sola vez?
#'
#' Cada fila debería tener un identificador propio. Si hay menos identificadores distintos que filas, hay repeticiones:
#'
unicidad <- tribble(
  ~dimension, ~comprobacion,                            ~incumplen,                                               ~base,
  "Unicidad", "operaciones con identificador repetido", nrow(o) - n_distinct(o$operacion_id),                     nrow(o),
  "Unicidad", "clientes con identificador repetido",    nrow(d$clientes) - n_distinct(d$clientes$cliente_id),     nrow(d$clientes),
  "Unicidad", "productos con identificador repetido",   nrow(d$productos) - n_distinct(d$productos$producto_id),  nrow(d$productos),
  "Unicidad", "sedes con identificador repetido",       nrow(d$sedes) - n_distinct(d$sedes$sede_id),              nrow(d$sedes),
  "Unicidad", "campañas con identificador repetido",    nrow(d$campanas) - n_distinct(d$campanas$campana_id),     nrow(d$campanas))
unicidad

#' ## 3. Validez: ¿cumple las reglas del negocio?
#'
#' Escribimos las reglas **por escrito** (no «de memoria») y contamos cuántas filas las incumplen.
#'
validez <- tribble(
  ~dimension, ~comprobacion,                           ~incumplen,                                                              ~base,
  "Validez",  "unidades >= 1",                         sum(o$unidades < 1),                                                     nrow(o),
  "Validez",  "precio_unitario > 0",                   sum(o$precio_unitario <= 0),                                             nrow(o),
  "Validez",  "descuento entre 0 y 1",                 sum(o$descuento_pct < 0 | o$descuento_pct > 1),                          nrow(o),
  "Validez",  "satisfacción entre 1 y 10 (si existe)", sum(o$satisfaccion < 1 | o$satisfaccion > 10, na.rm = TRUE),             nrow(o),
  "Validez",  "fecha dentro de 2022-2025",             sum(o$fecha < as.Date("2022-01-01") | o$fecha > as.Date("2025-12-31")),  nrow(o),
  "Validez",  "margen = ingresos - coste",             sum(abs(o$margen - (o$ingresos - o$coste)) > 0.02),                      nrow(o),
  "Validez",  "duración > 0",                          sum(o$duracion_min <= 0),                                                nrow(o),
  "Validez",  "precio de lista > coste (productos)",   sum(d$productos$precio_lista <= d$productos$coste_unitario),             nrow(d$productos),
  "Validez",  "fecha_fin >= fecha_inicio (campañas)",  sum(d$campanas$fecha_fin < d$campanas$fecha_inicio),                     nrow(d$campanas))
validez

#' ## 4. Consistencia: ¿cuadra entre tablas y dentro de cada columna?
#'
#' **4.1 Enlaces entre tablas.** `anti_join()` devuelve las filas que **no encuentran pareja**: operaciones que apuntan a un cliente, un servicio o una sede que no existe.
#'
enlaces <- tribble(
  ~dimension,     ~comprobacion,             ~incumplen,                                          ~base,
  "Consistencia", "operación sin cliente",   nrow(anti_join(o, d$clientes,  by = "cliente_id")),  nrow(o),
  "Consistencia", "operación sin servicio",  nrow(anti_join(o, d$productos, by = "producto_id")), nrow(o),
  "Consistencia", "operación sin sede",      nrow(anti_join(o, d$sedes,     by = "sede_id")),     nrow(o))
enlaces

#' **4.2 Lo mismo escrito de formas distintas.** Mira cómo se escribe el canal de alta de los clientes:
#'
d$clientes |> count(canal_alta)

#' ¿Ves «web» y «Web »? Es el mismo canal, pero R los cuenta por separado. Para detectarlo, comparamos el texto original con una versión en minúsculas y sin espacios sobrantes:
#'
canal_limpio <- str_to_lower(str_squish(d$clientes$canal_alta))

escritura <- tribble(
  ~dimension,     ~comprobacion,                          ~incumplen,                                  ~base,
  "Consistencia", "canal_alta escrito de forma distinta", sum(d$clientes$canal_alta != canal_limpio),  nrow(d$clientes))
escritura

#' **4.3 Coherencia en el tiempo.** Una operación no debería ocurrir antes de que exista el cliente, el servicio o la sede. Primero traemos esas tres fechas a cada operación:
#'
oj <- o |>
  left_join(select(d$clientes,  cliente_id, fecha_alta),         by = "cliente_id") |>
  left_join(select(d$productos, producto_id, fecha_lanzamiento), by = "producto_id") |>
  left_join(select(d$sedes,     sede_id, fecha_apertura),        by = "sede_id")

tiempo <- tribble(
  ~dimension,     ~comprobacion,                                   ~incumplen,                             ~base,
  "Consistencia", "operación anterior al alta del cliente",        sum(oj$fecha < oj$fecha_alta),          nrow(o),
  "Consistencia", "operación anterior al lanzamiento del servicio", sum(oj$fecha < oj$fecha_lanzamiento), nrow(o),
  "Consistencia", "operación anterior a la apertura de la sede",   sum(oj$fecha < oj$fecha_apertura),      nrow(o))
tiempo

#' ## 5. El cuadro de calidad
#'
#' Juntamos todas las tablas en una. El **semáforo** lo decides tú con un umbral.
#'
# >>> TOCA AQUÍ: cambia el umbral y vuelve a ejecutar la celda <<<
UMBRAL_ROJO <- 1       # % de filas afectadas a partir del cual es rojo
# verde = 0 incumplimientos · ámbar = hay, pero por debajo del umbral · rojo = igual o por encima

cuadro <- bind_rows(completitud, unicidad, validez, enlaces, escritura, tiempo) |>
  mutate(pct = round(100 * incumplen / base, 2),
         semaforo = case_when(incumplen == 0    ~ "verde",
                              pct < UMBRAL_ROJO ~ "ámbar",
                              TRUE              ~ "rojo"))

# Solo lo que no está en verde, de más a menos grave
cuadro |> filter(semaforo != "verde") |> arrange(desc(pct))

cuadro |>
  filter(incumplen > 0) |>
  ggplot(aes(x = pct, y = reorder(comprobacion, pct), fill = semaforo)) +
  geom_col() +
  scale_fill_manual(values = c(`ámbar` = "#F2B84B", rojo = "#F26B5B")) +
  labs(title = "Qué falla y cuánto", x = "% de filas afectadas", y = NULL, fill = NULL) +
  theme_marca(base_size = 13)

#' > ### Para pensar
#' > 1. ¿Qué dimensión falla más? ¿Es **la que más importa** para calcular ingresos, margen o satisfacción?
#' > 2. Hay problemas en **rojo** que no son errores de tecleo sino de **proceso** (fechas que no cuadran entre tablas). ¿Quién en la empresa podría explicarlos?
#' > 3. Las filas duplicadas son solo 8 en 19.000. ¿Merece la pena arreglarlas? ¿Y si cada una fuera un pedido de 50.000 €?
#' > 4. Todas las claves y todos los `JOIN` están perfectos. ¿Significa eso que los **datos** están bien?
#'
#' ### Toca esto
#'
#' Sube `UMBRAL_ROJO` a 5 y ejecuta de nuevo. ¿Qué problemas pasan de rojo a ámbar? ¿Estás de acuerdo con el semáforo resultante? **El umbral es una decisión de negocio, no técnica.**
