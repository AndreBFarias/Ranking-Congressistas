<div align="center">

[![Licença](https://img.shields.io/badge/licença-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![R](https://img.shields.io/badge/R-4.0+-green.svg)](https://www.r-project.org/)
[![Estrelas](https://img.shields.io/github/stars/AndreBFarias/RankingCongressistas.svg?style=social)](https://github.com/AndreBFarias/RankingCongressistas/stargazers)
[![Contribuições](https://img.shields.io/badge/contribuições-bem--vindas-brightgreen.svg)](https://github.com/AndreBFarias/RankingCongressistas/issues)

<div style="text-align: center;">
  <h1 style="font-size: 2em;">Ranking Congressistas</h1>
  <img src="assets/logo.png" width="200" alt="Ícone do Congresso" font-aligh="center">
</div>
</div>
Uma ferramenta open source para coletar discursos e projetos do Congresso Brasileiro, processar com regex para temas específicos e gerar rankings de deputados/senadores. Identifica quem é pró/contra um tema, com score de conversão para lobistas focarem nos mais influenciáveis. Dados da API Dados Abertos (Câmara e Senado).

---

### Pré-requisitos
- R 4.0 ou superior.
  
 #### Pacotes: 
  - tidyverse
  - rvest
  -  RCurl 
  -  glue
  - lubridate 
  - jsonlite
  - httr 
  - textreadr 
  - doMC
  - readxl
  - stringr

### Instalação

```bash
# Instale pacotes no R:
install.packages(c("tidyverse", "rvest", "RCurl", "glue", "lubridate", "jsonlite", "httr", "textreadr", "doMC", "readxl", "stringr"))
```
### Uso

- Execute Coleta_Camara_Discursos.R para discursos da Câmara.
- Execute Coleta_Senado_Discursos.R para discursos do Senado.
(Aplique regex personalizada para temas pró/contra.)
- Execute Ranking_Deputados.R e Ranking_Senadores.R para scores.


### Dependências
Bibliotecas open source para extração e análise.

### Licença
GLP - Livre para modificar e usar em rituais lobistas desde que tudo permaneça livre.
