library(readr)
library(readxl)
library(stringr)
library(tidyverse)


#discursos_camara <- read_csv("deputadoes_discursos_2015_2020_regex.csv")
projetos_camara <- read_csv("base_projetos_camara_reduzido_2015_2020_regex.csv")

## Agrupamento de projetos por deputado

#table(projetos_camara$Autor_Tipo)

projetos_camara <- projetos_camara[grepl("Deputado",projetos_camara$Autor_Tipo),]

projetos_camara <- projetos_camara[,c(16,18:103)]
colnames(projetos_camara)[1] <- "deputado"
projetos_camara$deputado <- toupper(projetos_camara$deputado)
projetos_camara <- projetos_camara[!grepl("SENADO",projetos_camara$deputado),]

projetos_camara <- projetos_camara %>% 
                   mutate(deputado = strsplit(as.character(deputado), ", ")) %>% 
                   unnest(deputado)

projetos_camara$deputado <- trimws(projetos_camara$deputado)

projetos_por_deputado <- projetos_camara %>%
  group_by(deputado) %>%
  summarise(across(everything(), list(sum)))

projetos_por_deputado$total_projetos <- rowSums(projetos_por_deputado[,c(2:ncol(projetos_por_deputado))])
projetos_por_deputado <- projetos_por_deputado[,c("deputado","total_projetos")]
