[![opensource](https://badges.frapsoft.com/os/v1/open-source.png?v=103)](#)
[![Licença](https://img.shields.io/badge/licença-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![R](https://img.shields.io/badge/R-4.0+-green.svg)](https://www.r-project.org/)
[![Estrelas](https://img.shields.io/github/stars/AndreBFarias/RankingCongressistas.svg?style=social)](https://github.com/AndreBFarias/RankingCongressistas/stargazers)
[![Contribuições](https://img.shields.io/badge/contribuições-bem--vindas-brightgreen.svg)](https://github.com/AndreBFarias/RankingCongressistas/issues)

# Ranking Congressistas

![Ícone do Congresso](https://raw.githubusercontent.com/AndreBFarias/Ranking-Congressistas/main/assets/logo.png)

## Descrição

Ferramenta para coletar discursos e projetos do Congresso Brasileiro via API Dados Abertos, processar com regex para temas específicos e gerar rankings de deputados e senadores. Identifica posicionamento pró/contra um tema com score ponderado. Dados da API Dados Abertos (Câmara e Senado).

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

- Execute `Coleta_camara.R` para discursos da Câmara.
- Execute `Coleta_senado.R` para discursos do Senado.
  (Aplique regex personalizada para temas pró/contra.)
- Execute `Ranking_Politicos_Deputados.R` e `Ranking_Congresso_Senadores.R` para os scores.


### Dependências
Bibliotecas open source para extração e análise.

### Licença
GPLv3 — Livre para usar, modificar e redistribuir, desde que as versões derivadas mantenham a mesma licença.
