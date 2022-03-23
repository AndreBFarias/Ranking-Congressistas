# Ritual de Magia Negra Digital: Ranking_Deputados.R - Alquimia de scores, transmutando palavras em rankings para caçar almas convertíveis.
# Explicação do Ritual: Ranking_Deputados.R.md

# 1. Lê base de discursos da Câmara atual.
# 2. Lê base de projetos (assumindo pré-processada com regex para temas).
# 3. Filtra autores deputados.
# 4. Seleciona colunas relevantes, normaliza nomes.
# 5. Desagrega autores múltiplos.
# 6. Limpa espaços em nomes.
# 7. Agrupa e soma por deputado.
# 8. Calcula total de projetos.
# 9. Agrupa discursos por orador.
# 10. Lista única de deputados.
# 11. Junta dados em ranking, preenche NAs.
# 12. Normaliza scores.
# 13. Calcula score de conversão (média normalizada).
# 14. Ordena por score descendente.
# 15. Salva CSV com ranking.

library(readr)
library(readxl)
library(stringr)
library(tidyverse)

# 1
discursos_camara <- readRDS("base_discursos_camara_2023_atual.rds")

# 2
projetos_camara <- read_csv("base_projetos_camara_2023_atual.csv")

# 3
projetos_camara <- projetos_camara[grepl("Deputado", projetos_camara$Autor_Tipo), ]

# 4
projetos_camara <- projetos_camara[, c(16, 18:103)]
colnames(projetos_camara)[1] <- "deputado"
projetos_camara$deputado <- toupper(projetos_camara$deputado)
projetos_camara <- projetos_camara[!grepl("SENADO", projetos_camara$deputado), ]

# 5
projetos_camara <- projetos_camara %>% 
  mutate(deputado = strsplit(as.character(deputado), ", ")) %>% 
  unnest(deputado)

# 6
projetos_camara$deputado <- trimws(projetos_camara$deputado)

# 7
projetos_por_deputado <- projetos_camara %>%
  group_by(deputado) %>%
  summarise(across(everything(), list(sum)))

# 8
projetos_por_deputado$total_projetos <- rowSums(projetos_por_deputado[, c(2:ncol(projetos_por_deputado))])
projetos_por_deputado <- projetos_por_deputado[, c("deputado", "total_projetos")]

# 9
discursos_por_deputado <- discursos_camara %>%
  group_by(orador) %>%
  summarise(total_discursos = n())

# 10
lista_deputados <- unique(c(projetos_por_deputado$deputado, discursos_por_deputado$orador))

# 11
ranking_deputados <- data.frame(deputado = lista_deputados)
ranking_deputados <- left_join(ranking_deputados, projetos_por_deputado, by = "deputado")
ranking_deputados <- left_join(ranking_deputados, discursos_por_deputado, by = c("deputado" = "orador"))
ranking_deputados[is.na(ranking_deputados)] <- 0

# 12
ranking_deputados <- transform(ranking_deputados, projetos_norm = (total_projetos - min(total_projetos)) / (max(total_projetos) - min(total_projetos)))
ranking_deputados <- transform(ranking_deputados, discursos_norm = (total_discursos - min(total_discursos)) / (max(total_discursos) - min(total_discursos)))

# 13
ranking_deputados$score_conversao <- (ranking_deputados$projetos_norm + ranking_deputados$discursos_norm) / 2

# 14
ranking_deputados <- ranking_deputados %>% arrange(desc(score_conversao))

# 15
write_csv(ranking_deputados, "ranking_deputados_2023_atual.csv")

# "A liberdade é o fogo que consome as correntes do estado." — Ludwig von Mises