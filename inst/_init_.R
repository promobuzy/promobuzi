
# informa lista de urls para baixar, pode vir de uma planilha em excel.

lista <- openxlsx::read.xlsx("Automação - Amazon.xlsx",sheet = 1, colNames = F) |>
  dplyr::pull()

lista <- "https://amzn.to/4a0U7dF"

# informa diretorio onde dados devem ser salvos.
diretorio <- "data-raw/"

## Baixa Paginas da Web.
baixar_paginas(lista_url = lista, diretorio = diretorio)

# Lista os arquivos baixados.
arquivos <- list.files(diretorio, full.names = T)

# Lê arquivos, para cada loja existe um função especifica para ler dados da pagina
dados_amz <- ler_amazon(diretorio = diretorio)

dados_mgl <- ler_magazine_luiza(diretorio = diretorio)
dados_mcl <- ler_mercado_livre(diretorio = diretorio)

# Unifica data frames
dados <- dplyr::bind_rows(dados_amz, dados_mgl, dados_mcl)

# Salva dados em formato xlsx na pata raiz, pode informar o diretorio completo "{seu/caminho/personalizado}/dados.xlsx"

caminho_excel <- "Automação - Amazon.xlsx"
wb <- openxlsx::loadWorkbook(caminho_excel)
openxlsx::writeData(wb, sheet = 2, dados)
openxlsx::saveWorkbook(wb,caminho_excel, overwrite = T )


