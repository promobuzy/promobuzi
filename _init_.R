
# informa diretorio onde dados devem ser salvos.
diretorio <- "logs_automacao/"

# nome do arquivo excel de Links IN - Input de links para webscraping
path <- "Links_IN/lista_links.xlsx"

# informa lista de urls para baixar, pode vir de uma planilha em excel.
lista_url <- openxlsx::read.xlsx(path,sheet = 1, colNames = F) |>
  dplyr::pull()

# Usado para teste único
url_teste <- c("https://divulgador.magalu.com/gnF34NqT")

## Baixa Paginas da Web.
source('~/Projetos/promobuzi/Funcoes_R/baixar_paginas.R')
baixar_paginas(lista_url = lista_url, diretorio = diretorio)


# Lê arquivos, para cada loja existe um função especifica para ler dados da pagina
source('~/Projetos/promobuzi/Funcoes_R/ler_amazon.R')
dados_amz <- ler_amazon(diretorio = diretorio)

source('~/Projetos/promobuzi/Funcoes_R/ler_mercado_livre.R')
dados_mcl <- ler_mercado_livre(diretorio = diretorio)

source('~/Projetos/promobuzi/Funcoes_R/ler_magazine_luiza.R')
dados_mgl <- ler_magazine_luiza(diretorio = diretorio)


# Unifica data frames
dados <- dplyr::bind_rows(dados_amz, dados_mcl, dados_mgl)

# Salva dados em formato xlsx na pata raiz, pode informar o diretorio completo "{seu/caminho/personalizado}/dados.xlsx"

caminho_excel <- "Links_OUT/dados.xlsx"
wb <- openxlsx::loadWorkbook(caminho_excel)
openxlsx::writeData(wb, sheet = 2, dados)
openxlsx::saveWorkbook(wb,caminho_excel, overwrite = T )


