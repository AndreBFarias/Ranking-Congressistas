library(readr)
library(readxl)
library(stringr)
library(tidyverse)


discursos_senado <- read_csv("senadores_discursos_2015_2020_regex.csv")
projetos_senado <- read_xlsx("base_projetos_senado_2015_2020_regex.xlsx")

## Agrupamento de discursos por senador

discursos_senado$senador <- str_extract(discursos_senado$titulo,'(?<=Pronunciamento de ).*(?= em)')
discursos_senado <- discursos_senado[,c(6:92)]

discursos_por_senador <- discursos_senado %>%
                         group_by(senador) %>%
                         summarise(across(everything(), list(sum)))

discursos_por_senador$total_discursos <- rowSums(discursos_por_senador[,c(2:ncol(discursos_por_senador))])
discursos_por_senador <- discursos_por_senador[,c("senador","total_discursos")]

## Agrupamento de projetos por senador

table(projetos_senado$AutorPrincipal.IdentificacaoParlamentar.NomeParlamentar)

projetos_senado <- projetos_senado[,c(29,66:151)]

projetos_por_senador <- projetos_senado %>%
                        group_by(AutorPrincipal.IdentificacaoParlamentar.NomeParlamentar) %>%
                        summarise(across(everything(), list(sum)))

projetos_por_senador$total_projetos <- rowSums(projetos_por_senador[,c(2:ncol(projetos_por_senador))])
projetos_por_senador <- projetos_por_senador[,c("AutorPrincipal.IdentificacaoParlamentar.NomeParlamentar","total_projetos")]
colnames(projetos_por_senador)[1] <- "senador"

## Montando o ranking

lista_senadores <- discursos_por_senador$senador
lista_senadores <- append(lista_senadores,projetos_por_senador$senador)
lista_senadores <- unique(lista_senadores)
lista_senadores <- lista_senadores[!is.na(lista_senadores)]

ranking_senadores <- data.frame(senador = lista_senadores)
ranking_senadores <- dplyr::left_join(ranking_senadores,projetos_por_senador,by=c("senador"))
ranking_senadores <- dplyr::left_join(ranking_senadores,discursos_por_senador,by=c("senador"))
ranking_senadores[is.na(ranking_senadores)] <- 0

ranking_senadores <- transform(ranking_senadores, projetos_norm = (total_projetos - min(total_projetos)) / (max(total_projetos) - min(total_projetos)))
ranking_senadores <- transform(ranking_senadores, discursos_norm = (total_discursos - min(total_discursos)) / (max(total_discursos) - min(total_discursos)))

ranking_senadores$projetos_x_discursos <- (ranking_senadores$projetos_norm + ranking_senadores$discursos_norm)/2

ranking_senadores <- ranking_senadores %>% arrange(desc(projetos_x_discursos))

library(writexl)

write_xlsx(ranking_senadores,"ranking_senadores.xlsx")
