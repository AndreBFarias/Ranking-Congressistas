# Ritual de Magia Negra Digital: Coleta_Camara_Discursos.R - Invocação das vozes ocultas da Câmara, extraindo discursos como ecos de um coven parlamentar.
# Explicação do Ritual: Coleta_Camara_Discursos.R.md

# 1. Define o início da legislatura atual (57ª, 2023).
# 2. Calcula intervalos mensais até hoje.
# 3. Ajusta datas de fim para cada mês.
# 4. Formata datas para consulta na API.
# 5. Constrói URLs para listar discursos.
# 6. Lê XML de cada URL.
# 7. Conta sessões por XML.
# 8. Extrai detalhes de cada sessão e discurso.
# 9. Constrói dataframe com dados extraídos.
# 10. Função para decodificar RTF de discursos.
# 11. Gera URLs para teor completo dos discursos.
# 12. Define diretório de trabalho.
# 13. Configura paralelismo com doMC.
# 14. Baixa conteúdo das URLs em paralelo com retries.
# 15. Identifica erros nas respostas.
# 16. Lê XML dos URLs com erro.
# 17. Combina respostas válidas.
# 18. Parseia XML final.
# 19. Extrai teor completo e metadados.
# 20. Salva RDS com base atualizada.

library(tidyverse)
library(rvest)
library(RCurl)
library(glue)
library(lubridate)

# 1
inicio_legislatura <- "01/02/2023" %>% dmy()

# 2
inicio <- interval(inicio_legislatura, today()) %>%
  time_length("month") %>%
  trunc() %>% 
  {inicio_legislatura + months(1:.)}

# 3
fim <- inicio + months(1) - 1
fim[length(fim)] <- today()

# 4
inicio <- format(inicio, "%d/%m/%Y")
fim <- format(fim, "%d/%m/%Y")

# 5
c_url2 <- paste0("https://www.camara.leg.br/sitcamaraws/SessoesReunioes.asmx/ListarDiscursosPlenario?dataIni=", inicio, "&dataFim=", fim, "&codigoSessao=&parteNomeParlamentar=&siglaPartido=&siglaUF=")

# 6
lista_discurso <- c_url2 %>% 
  map(~{
    .x %>%
      read_xml()
  })

# 7
lista_sessoes <- lista_discurso %>% 
  map(~{
    .x %>% 
      xml_children() %>%
      xml_name() %>%
      length()
  }) %>% unlist()

# 8
l <- map2(lista_discurso, lista_sessoes, ~{
  s <- .x
  map(1:.y, ~{
    codSessao <- xml_find_all(s, paste0("//sessao[", .x, "]/codigo")) %>% xml_text(trim = T)
    data <- xml_find_all(s, paste0("//sessao[", .x, "]/data")) %>% xml_text(trim = T)
    numero_sessao <- xml_find_all(s, paste0("//sessao[", .x, "]/numero")) %>% xml_text(trim = T)
    tipo_sessao <- xml_find_all(s, paste0("//sessao[", .x, "]/tipo")) %>% xml_text(trim = T)
    codigo_faseSessao <- xml_find_all(s, paste0("//sessao[", .x, "]/fasesSessao/faseSessao/codigo")) %>% xml_text(trim = T)
    descricao_faseSessao <- xml_find_all(s, paste0("//sessao[", .x, "]/fasesSessao/descricao")) %>% xml_text(trim = T)
    hora_discurso <- xml_find_all(s, paste0("//sessao[", .x, "]/fasesSessao/faseSessao/discursos/discurso/horaInicioDiscurso")) %>% xml_text(trim = T)
    txtIndexaxao <- xml_find_all(s, paste0("//sessao[", .x, "]/fasesSessao/faseSessao/discursos/discurso/txtIndexacao")) %>% xml_text(trim = T)
    numeroQuarto <- xml_find_all(s, paste0("//sessao[", .x, "]/fasesSessao/faseSessao/discursos/discurso/numeroQuarto")) %>% xml_text(trim = T)
    numeroInsercao <- xml_find_all(s, paste0("//sessao[", .x, "]/fasesSessao/faseSessao/discursos/discurso/numeroInsercao")) %>% xml_text(trim = T)
    sumario <- xml_find_all(s, paste0("//sessao[", .x, "]/fasesSessao/faseSessao/discursos/discurso/sumario")) %>% xml_text(trim = T)
    numero_orador <- xml_find_all(s, paste0("//sessao[", .x, "]/fasesSessao/faseSessao/discursos/discurso/orador/numero")) %>% xml_text(trim = T)
    nome_orador <- xml_find_all(s, paste0("//sessao[", .x, "]/fasesSessao/faseSessao/discursos/discurso/orador/nome")) %>% xml_text(trim = T)
    partido_orador <- xml_find_all(s, paste0("//sessao[", .x, "]/fasesSessao/faseSessao/discursos/discurso/orador/partido")) %>% xml_text(trim = T)
    uf_orador <- xml_find_all(s, paste0("//sessao[", .x, "]/fasesSessao/faseSessao/discursos/discurso/orador/uf")) %>% xml_text(trim = T)
    
    cbind(codSessao, data, numero_sessao, tipo_sessao,
          codigo_faseSessao, descricao_faseSessao,
          hora_discurso, txtIndexaxao, numeroQuarto, numeroInsercao, sumario,
          numero_orador, nome_orador, partido_orador, uf_orador)  
  })
})

# 9
df <- map_dfr(seq_along(lista_sessoes), ~{
  listaDetalhe <- l[[.x]]
  map_dfr(1:length(listaDetalhe), ~{
    as.data.frame(listaDetalhe[[.x]], stringsAsFactors = FALSE)
  })
})

# 10
decode_rtf <- function(txt) {
  txt %>%
    base64Decode %>%
    str_replace_all("\\\\'e3", "ã") %>%
    str_replace_all("\\\\'e1", "á") %>%
    str_replace_all("\\\\'e9", "é") %>%
    str_replace_all("\\\\'e7", "ç") %>%
    str_replace_all("\\\\'ed", "í") %>%
    str_replace_all("\\\\'f3", "ó") %>%
    str_replace_all("\\\\'ea", "ê") %>%
    str_replace_all("\\\\'e0", "à") %>%
    str_replace_all("(\\\\[[:alnum:]']+|[\\r\\n]|^\\{|\\}$)", "") %>%
    str_replace_all("\\{\\{[[:alnum:]; ]+\\}\\}", "") %>%
    str_trim
}

# 11
discursos_url <- glue("https://www.camara.leg.br/SitCamaraWS/SessoesReunioes.asmx/obterInteiroTeorDiscursosPlenario?codSessao={df$codSessao}&numOrador={df$numero_orador}&numQuarto={df$numeroQuarto}&numInsercao={df$numeroInsercao}")

# 12
setwd("~/Desktop/DiscursosCongresso")

# 13
library(doMC)
nr_cores <- 60
registerDoMC(nr_cores)

# 14
res_ds_url <- foreach(ds_url = discursos_url) %dopar% {
  tryCatch({
    curlhand <- getCurlHandle() 
    curlSetOpt(.opts = list(forbid.reuse = 1), curl = curlhand) 
    retry(getURL(ds_url, curl = curlhand), max = 10, init = 0)
  }, error = function(e) {
    tryCatch({
      curlhand <- getCurlHandle() 
      curlSetOpt(.opts = list(forbid.reuse = 1), curl = curlhand) 
      retry(getURL(ds_url, curl = curlhand), max = 10, init = 0)
    }, error = function(e) {
      paste0(ds_url, " ## DOUBLE ERROR")
    })
  })
}

# 15
saida <- unlist(res_ds_url)
erro <- which(!grepl('<?xml version=\"1.0\"', saida))
urls_com_erro <- as.list(discursos_url[erro])

# 16
res_ds_url__erro <- lapply(urls_com_erro, read_xml)

# 17
res_ds_url_final <- c(res_ds_url[-erro], res_ds_url__erro)
res_ds_url_final <- res_ds_url_final[grepl('<?xml version=\"1.0\"', res_ds_url_final)]

# 18
res_ds_url_xml_final <- lapply(res_ds_url_final, read_xml, options = "HUGE")

# 19
inteiro_teor <- map_dfr(1:length(res_ds_url_xml_final), ~{
  l <- res_ds_url_xml_final[[.x]]
  orador <- xml_find_first(l, "//nome") %>% xml_text()
  partido <- xml_find_first(l, "//partido") %>% xml_text()
  uf <- xml_find_first(l, "//uf") %>% xml_text()
  horaInicioDiscurso <- xml_find_all(l, "//horaInicioDiscurso") %>% xml_text()
  inteiro <- xml_find_all(l, "//discursoRTFBase64") %>%
    xml_text() %>% 
    decode_rtf()
  cbind(orador, partido, uf, horaInicioDiscurso, inteiro) %>% as_tibble()
})

# 20
saveRDS(inteiro_teor, 'base_discursos_camara_2023_atual.rds')

# "O poder é como uma sombra: quanto mais se busca, mais ela se alonga." 