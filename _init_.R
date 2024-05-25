
# informa diretorio onde dados brutos das paginas devem ser salvos.
diretorio <- "logs_automacao/"

# nome do arquivo excel de Links IN - Input de links para webscraping
path <- "Links_IN/lista_links.xlsx"

# informa lista de urls para baixar, pode vir de uma planilha em excel.
lista_url <- openxlsx::read.xlsx(path,sheet = 1, colNames = F) |>
  dplyr::pull()

# Usado para teste único
lista_url <- c("https://divulgador.magalu.com/GhmcUftQ")


## Baixa Paginas da Web.
source('~/Projetos/promobuzi/Funcoes_R/baixar_paginas.R')
baixar_paginas(lista_url = lista_url, diretorio = diretorio)


source('~/Projetos/promobuzi/Funcoes_R/ler_lojas.R')
le_lojas (AMZ = 1,
          ML = 1,
          MGL = 1,
          dir_funcoes_R = "~/Projetos/promobuzi/Funcoes_R",
          dir_output = "~/Projetos/promobuzi/Links_OUT",
          dir_logs  = '~/Projetos/promobuzi/logs_automacao')




  #/// Teste de leitura de dados /// Utilizado na camada de desenvolvimento
#================================================================================================

# Lê arquivos, para cada loja existe um função especifica para ler dados da pagina
source('~/Projetos/promobuzi/Funcoes_R/ler_amazon.R')
dados_amz <- ler_amazon(diretorio = diretorio)

source('~/Projetos/promobuzi/Funcoes_R/ler_mercado_livre.R')
dados_mcl <- ler_mercado_livre(diretorio = diretorio)

source('~/Projetos/promobuzi/Funcoes_R/ler_magazine_luiza.R')
dados_mgl <- ler_magazine_luiza(diretorio = diretorio)


# Unifica data frames
dados <- dplyr::bind_rows(dados_amz, dados_mcl, dados_mgl)






