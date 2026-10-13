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