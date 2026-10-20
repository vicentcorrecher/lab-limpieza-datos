# Regenera los seis .html (con la marca de assets/marca.css) a partir de los .Rmd.
# Ejecutar con la carpeta del proyecto como directorio de trabajo: abre laboratorios.Rproj y pulsa "Source".
# Cada laboratorio se ejecuta en un entorno limpio, igual que lo haría una persona desde cero.
labs <- sprintf("lab%s", c("0_conexion", "1_auditoria", "2_depuracion", "3_faltantes", "4_impacto_kpis", "5_dato_sucio"))
for (l in labs) {
  message("Generando ", l, ".html ...")
  rmarkdown::render(paste0(l, ".Rmd"), envir = new.env(), quiet = TRUE)
}
message("Listo: ", length(labs), " informes generados.")
