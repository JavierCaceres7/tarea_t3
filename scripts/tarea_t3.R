# =============================================================================
# Tarea T3 — Regresión económica: CASEN y ENE
# Fundamentos de Programación para Análisis Económico · UdeC-EAN
#
# Autor: Javier Ignacio Cáceres Venegas
# Fecha: Octubre 2026
#
# Objetivo: Estimar, extraer, comparar, diagnosticar e interpretar modelos 
#           de regresión utilizando CASEN y la ENE.
# =============================================================================
#cargamos las librerias a usar en este proyecto
library(dplyr)
library(broom)
library(modelsummary)

# =============================================================================
# PARTE A — CASEN
# =============================================================================

casen <- read.csv("data/raw/casen_reducido.csv") |>
  mutate(experiencia = pmax(edad - educ - 6, 0))
#modelos base 
m1 <- lm(ingreso ~ educ, data = casen)
m2 <- lm(ingreso ~ educ + experiencia + genero, data = casen)
# A2. La tabla de coeficientes, con `broom` + `dplyr`
coefs_m2 <- tidy(m2, conf.int = TRUE) |>
  filter(term != "(Intercept)") |>
  mutate(
    estimate  = round(estimate, 1),
    conf.low  = round(conf.low, 1),
    conf.high = round(conf.high, 1),
    p.value   = round(p.value, 4),
    sig_5p  = p.value < 0.05
  ) |>
  arrange(p.value) |>
  select(term, estimate, conf.low, conf.high, p.value, sig_5p)

coefs_m2
### A3. Comparar modelos
m3 <- lm(ingreso ~ educ + experiencia + I(experiencia^2) + genero, data = casen)

modelos_casen <- list(simple = m1, controles = m2, mio = m3)
comparacion_glance <- lapply(modelos_casen, glance) |> 
  bind_rows(.id = "modelo") |>
  select(modelo, r.squared, adj.r.squared, nobs)
comparacion_glance
#Al agregar la variable I(experiencia^2) el R2 adj disminuye esto quiere decir que 
# castiga a modelo diciendole que agregar esa variable empeora su poder explicativo 


### A4. ¿Cambió el coeficiente de educación?
bind_rows(simple = tidy(m1), controles = tidy(m2), mio = tidy(m3), .id = "modelo") |>
  filter(term == "educ") |>
  select(modelo, estimate, std.error, p.value)
  
# para que un control mueva un coeficiente tiene que estar correlacionado en este caso 
# con el ingreso y con el ingreso(variable de interes y dependiente). En este caso 
# si cambia con el coeficiente por lo que lo anterior se cumple.

### A5. Diagnóstico

# 1. Las tres personas peor predichas
peor_predichas <- augment(m2) |>
  select(ingreso, educ, experiencia, genero, .fitted, .resid) |>
  mutate(across(c(.fitted, .resid), round)) |>
  arrange(desc(abs(.resid))) |>
  head(3)

#Las 3 peores personas predichas cuentan con alto residuo absoluto, en teoria podriamos 
# decir que tienen muy altos o bajos ingresos mostrando asi datos atipicos, pero tambien 
# podemos obsservar que son personas con alta experiencia  y sueldos relaticamnete bajos.
# 2. Maxima distancia de cook y maximo apalancamiento hat
diagnosticos_max <- augment(m2) |>
  summarise(
    max_cooksd = max(.cooksd, na.rm = TRUE),
    max_hat    = max(.hat, na.rm = TRUE)
  )

diagnosticos_max

# 3. Reestimar m2 sin fila mayor distancia cook 

fila_mayor_cook <- augment(m2) |>
  slice_max(.cooksd, n = 1) |>
  pull(.rownames) |>
  as.numeric()

nuevo_m2 <- casen |>
  filter(row_number() != fila_mayor_cook) |>
  lm(ingreso ~ educ + experiencia + genero, data = _)

bind_rows(
  con_todos      = tidy(m2), 
  sin_mayor = tidy(nuevo_m2), 
  .id = "muestra"
) |>
  filter(term == "educ") |>
  select(muestra, estimate, std.error, p.value)

### A6. Interpretación de la Parte A
#En el modelo con controles, cada año adicional de educación se asocia con
# $42245.8 más de ingreso mensual, en promedio, manteniendo experiencia y
# género constantes (IC 95 %: $29487 a $55004).»
#
#El coeficiente de `generoM` es $55686. Esto significa que a igual educacion y experiencia 
#los hombres perciben un ingreso de 55686 pesosen promedio mas que las mujeres. Sin embargo 
# su p value es de 0.204 por lo que al 5% esto no es estadisticamente significativo en  esta muestra

# =============================================================================
# PARTE B — ENE: Pregunta propia sobre el mercado laboral
# =============================================================================
ene <- read.csv2("data/raw/ene-2026-06-mjj.csv")

regiones <- c("Tarapacá", "Antofagasta", "Atacama", "Coquimbo", "Valparaíso",
              "O'Higgins", "Maule", "Biobío", "La Araucanía", "Los Lagos",
              "Aysén", "Magallanes", "Metropolitana", "Los Ríos",
              "Arica y Parinacota", "Ñuble")

# B1. Pregunta declarada en comentario:
# ¿Se asocia el nivel educacional con la probabilidad de ser informal, y cuánto 
# de esa asociación se mantiene al controlar por género y edad en los ocupados?

### B2. Prepara la base
ocupados <- ene |>
  filter(activ == 1) |>                               
  mutate(
    informal   = ocup_form == 2,                      
    mujer      = sexo == 2,
    educ_anos  = na_if(cine11_1d, 9),                 
    region_txt = regiones[region]
  ) |>
  select(informal, mujer, edad, educ_anos, region_txt, fact_cal)

### B3. Al menos dos modelos
e_base     <- lm(informal ~ educ_anos, data = ocupados, weights = fact_cal)
e_controles <- lm(informal ~ educ_anos + mujer + edad, data = ocupados, weights = fact_cal)

# B4. Extraer y comparar con broom + dplyr
# 1. Tabla apilada de coeficientes de la variable de interés (educ_anos)
bind_rows(base = tidy(e_base), controles = tidy(e_controles), .id = "modelo") |>
  filter(term == "educ_anos") |>
  select(modelo, term, estimate, std.error, p.value)

#2. `glance()` de ambos modelos apilados.
lapply(list(base = e_base, con_controles = e_controles), glance) |>
  bind_rows(.id = "modelo") |>
  select(modelo, r.squared, nobs)

# 3. Regresión por grupo (por región) usando group_by() + group_modify() + tidy() con IC
brecha_region <- ocupados |>
  group_by(region_txt) |>
  group_modify(~ tidy(lm(informal ~ educ_anos + mujer + edad, data = .x, weights = fact_cal),
                      conf.int = TRUE)) |>
  filter(term == "educ_anos") |>
  ungroup() |>
  select(region_txt, estimate, std.error, conf.low, conf.high, p.value)

brecha_region

# B5. Análisis de sensibilidad 
e_sin_ponderar <- lm(informal ~ educ_anos + mujer + edad, data = ocupados)

bind_rows(ponderado = tidy(e_controles), sin_ponderar = tidy(e_sin_ponderar), .id = "tipo") |>
  filter(term == "educ_anos") |>
  select(tipo, estimate, std.error)



dir.create("data/processed", showWarnings = FALSE)

modelsummary(list("Base" = e_base, "Controles" = e_controles), output = "data/processed/t3_tabla_ene.csv")
tidy(e_controles, conf.int = TRUE) |> write.csv("data/processed/t3_coeficientes_casen.csv", row.names = FALSE)

### B6. Interpretación de la Parte B
#Los resultados de la ENE muestran que estudiar un año más se asocia con una
#caída de 10,41 puntos porcentuales en la probabilidad de pertenecer a la 
#informalidad, manteniendo fijos la edad y el sexo. Esta relación se mantiene
#prácticamente igual al agregar controles, lo que demuestra que la educación
#pesa harto por sí sola. Aunque con más de 40 mil datos casi todo sale
#estadísticamente significativo, la baja del 10% sí representa una importancia económica real y grande.
#Como limitaciones, hay que tener claro que esto no es causalidad 
#y que los errores estándar de R no corrigen el diseño muestral complejo de la encuesta.




