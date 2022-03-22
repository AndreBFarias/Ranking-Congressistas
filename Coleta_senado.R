library(tidyverse)
library(purrr)
library(plyr)
library(dplyr)
library(jsonlite)
library(httr)


senadores<-function(legislatura_inicio,legislatura_fim){
  url<-paste0("http://legis.senado.leg.br/dadosabertos/senador/lista/legislatura/",legislatura_inicio,"/",legislatura_fim)
  jsonlite::fromJSON(url)
}

leg_55_56<-senadores(55,56)


codigo_discurso<- leg_55_56 %>% 
  purrr::pluck(1) %>% 
  pluck(4) %>% 
  pluck(1) %>% 
  pluck(1) %>% 
  pull(1)


url_discurso<-paste0("https://legis.senado.leg.br/dadosabertos/senador/",codigo_discurso,"/discursos")

base <- url_discurso %>% map(fromJSON)

b <- base %>%
  modify_depth(3,~pluck(.x,2))

b1<-b %>% 
  map(~pluck(.x,1))

b2<-b1 %>% 
  map(~{
    .x %>% 
      pluck(4) %>% 
      pluck(1) %>% 
      pluck(9)
  })

b3<-map2_dfr(codigo_discurso,b2,~{
  cbind(.x,.y) %>% as_tibble()
  
})

saveRDS(b3,"urls_discursos_senado.rds")

f<-function(x){
  
  a<- read_html(x) %>% 
  html_nodes(xpath="//div[@id='content']") %>%
  html_text()
}

library(textreadr)
library(rvest)

d<-NULL
for(i in 1:length(b3$.y)){
  tryCatch({
  a<-f(b3$.y[[i]]) %>%
    tibble::as_tibble(validate=F) %>% 
    magrittr::set_names("discurso") %>%
    dplyr::mutate(codigo=b3$.x[[i]],
                  url_texto=b3$.y[[i]])
  d<-rbind(d,a)
  },error=function(e){
    
    e
  }, finally = {
    
    next
  })
  
}

d <- d[,c(2,3,1)]
table(d$codigo)

saveRDS(d,"base_discursos_senado.rds")
