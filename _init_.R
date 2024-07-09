
# informa diretorio onde dados brutos das paginas devem ser salvos.
diretorio <- "logs_automacao/"

# nome do arquivo excel de Links IN - Input de links para webscraping
path <- "Links_IN/lista_links.xlsx"

# informa lista de urls para baixar, pode vir de uma planilha em excel.
lista_url <- openxlsx::read.xlsx(path,sheet = 1, colNames = F) |>
  dplyr::pull()

# Usado para teste único
lista_url <- c("https://amzn.to/3DRjWhT")


## Baixa Paginas da Web.
source('~/projetos/promobuzi/Funcoes_R/baixar_paginas.R')
baixar_paginas(lista_url = lista_url, diretorio = diretorio)


source('~/Projetos/promobuzi/Funcoes_R/ler_lojas.R')
le_lojas (AMZ = 1,
          ML = 1,
          MGL = 1,
          dir_funcoes_R = "~/Projetos/promobuzi/Funcoes_R",
          dir_output = "~/Projetos/promobuzi/Links_OUT",
          dir_logs  = '~/Projetos/promobuzi/logs_automacao')



#Upload das Imagens da pasta para o Wordpress e Geração de links
source('~/Projetos/promobuzi/Funcoes_R/wp_direct_link.R')
wp_direct_link()

#Prepara os dados para serem enviados para o Worldpress
source('~/Projetos/promobuzi/Funcoes_R/preparar_para_worldpress.R')
preparar_para_worldpress()


