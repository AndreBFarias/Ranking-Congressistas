# Ritual de Magia Negra Digital: Coleta_Senado_Discursos.R - Conjuração das confissões senatoriaisd, tecendo teias de palavras proibidas do alto escalão.
# Explicação do Ritual: Coleta_Senado_Discursos.R.md

# 1. Função para listar senadores por legislatura.
# 2. Busca senadores da 57ª legislatura (atual, 2023-2026).
# 3. Extrai códigos de senadores.
# 4. Constrói URLs para discursos.
# 5. Lê JSON de cada URL.
# 6. Navega na estrutura JSON (profundidade 3).
# 7. Extrai camada adicional.
# 8. Extrai URLs de discursos.
# 9. Constrói dataframe com códigos e URLs.
# 10. Salva RDS com URLs.
# 11. Função para extrair texto de HTML.
# 12. Loop para coletar discursos, com tryCatch.
# 13. Reordena colunas.
# 14. Salva RDS com base atualizada.

library(tidyverse)
library(purrr)
library(plyr)
library(dplyr)
library(jsonlite)
library(httr)
library(rvest)
library(textreadr)

# 1
senadores <- function(legislatura_inicio, legislatura_fim) {
  url <- paste0("http://legis.senado.leg.br/dadosabertos/senador/lista/legislatura/", legislatura_inicio, "/", legislatura_fim)
  jsonlite::fromJSON(url)
}

# 2
leg_57 <- senadores(57, 57)

# 3
codigo_discurso <- leg_57 %>% 
  purrr::pluck(1) %>% 
  pluck(4) %>% 
  pluck(1) %>% 
  pluck(1) %>% 
  pull(1)

# 4
url_discurso <- paste0("https://legis.senado.leg.br/dadosabertos/senador/", codigo_discurso, "/discursos")

# 5
base <- url_discurso %>% map(fromJSON)

# 6
b <- base %>%
  modify_depth(3, ~pluck(.x, 2))

# 7
b1 <- b %>% 
  map(~pluck(.x, 1))

# 8
b2 <- b1 %>% 
  map(~{
    .x %>% 
      pluck(4) %>% 
      pluck(1) %>% 
      pluck(9)
  })

# 9
b3 <- map2_dfr(codigo_discurso, b2, ~{
  cbind(.x, .y) %>% as_tibble()
})

# 10
saveRDS(b3, "urls_discursos_senado.rds")

# 11
f <- function(x) {
  read_html(x) %>% 
    html_nodes(xpath = "//div[@id='content']") %>%
    html_text()
}

# 12
d <- NULL
for (i in 1:length(b3$.y)) {
  tryCatch({
    a <- f(b3$.y[[i]]) %>%
      tibble::as_tibble(validate = F) %>% 
      magrittr::set_names("discurso") %>%
      dplyr::mutate(codigo = b3$.x[[i]],
                    url_texto = b3$.y[[i]])
    d <- rbind(d, a)
  }, error = function(e) {
    e
  }, finally = {
    next
  })
}

# 13
d <- d[, c(2, 3, 1)]

# 14
saveRDS(d, "base_discursos_senado_2023_atual.rds")

# "A verdade é o veneno que cura a ilusão do poder." — Ayn Rand