# Ritual de Magia Negra Digital: Ranking_Senadores.R - Encantamento de influências, forjando rankings como lâminas para lobistas sedentos.
# Explicação do Ritual: Ranking_Senadores.R.md

# 1. Lê base de discursos do Senado atual.
# 2. Lê base de projetos (assumindo pré-processada).
# 3. Extrai nomes de senadores dos títulos.
# 4. Agrupa e conta discursos por senador.
# 5. Agrupa e conta projetos por senador.
# 6. Renomeia coluna para junção.
# 7. Lista única de senadores.
# 8. Junta dados em ranking, preenche NAs.
# 9. Normaliza scores.
# 10. Calcula score de conversão.
# 11. Ordena por score descendente.
# 12. Salva XLSX com ranking.
library(readr)
library(readxl)
library(stringr)
library(tidyverse)

# 1
discursos_senado <- readRDS("base_discursos_senado_2023_atual.rds")

# 2
projetos_senado <- read_xlsx("base_projetos_senado_2023_atual.xlsx")

# 3
discursos_senado$senador <- str_extract(discursos_senado$titulo, '(?<=Pronunciamento de ).*(?= em)')

# 4
discursos_por_senador <- discursos_senado %>%
  group_by(senador) %>%
  summarise(total_discursos = n())

# 5
projetos_por_senador <- projetos_senado %>%
  group_by(AutorPrincipal.IdentificacaoParlamentar.NomeParlamentar) %>%
  summarise(total_projetos = n())

# 6
colnames(projetos_por_senador)[1] <- "senador"

# 7
lista_senadores <- unique(c(discursos_por_senador$senador, projetos_por_senador$senador))
lista_senadores <- lista_senadores[!is.na(lista_senadores)]

# 8
ranking_senadores <- data.frame(senador = lista_senadores)
ranking_senadores <- left_join(ranking_senadores, projetos_por_senador, by = "senador")
ranking_senadores <- left_join(ranking_senadores, discursos_por_senador, by = "senador")
ranking_senadores[is.na(ranking_senadores)] <- 0

# 9
ranking_senadores <- transform(ranking_senadores, projetos_norm = (total_projetos - min(total_projetos)) / (max(total_projetos) - min(total_projetos)))
ranking_senadores <- transform(ranking_senadores, discursos_norm = (total_discursos - min(total_discursos)) / (max(total_discursos) - min(total_discursos)))

# 10
ranking_senadores$score_conversao <- (ranking_senadores$projetos_norm + ranking_senadores$discursos_norm) / 2

# 11
ranking_senadores <- ranking_senadores %>% arrange(desc(score_conversao))

# 12
write_xlsx(ranking_senadores, "ranking_senadores_2023_atual.xlsx")

# "O indivíduo é soberano, e o estado, seu servo relutante." — Friedrich Hayek