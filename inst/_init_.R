
# informa lista de urls para baixar, pode vir de uma planilha em excel.
lista_url <- openxlsx::read.xlsx("Captação de Ofertas.xlsx",sheet = 1, colNames = F) |>
  dplyr::filter(stringr::str_detect(X1, "magalu")) |>
  dplyr::pull()

lista_url <- c("https://amzn.to/3IWCa4g")

# informa diretorio onde dados devem ser salvos.
diretorio <- "data-raw/"

## Baixa Paginas da Web.

baixar_paginas(lista_url = lista_url, diretorio = diretorio)


# Lê arquivos, para cada loja existe um função especifica para ler dados da pagina
dados_amz <- ler_amazon(diretorio = diretorio)

dados_mcl <- ler_mercado_livre(diretorio = diretorio)

dados_mgl <- ler_magazine_luiza(diretorio = diretorio)


# Unifica data frames
dados <- dplyr::bind_rows(dados_amz, dados_mcl, dados_mgl)

# Salva dados em formato xlsx na pata raiz, pode informar o diretorio completo "{seu/caminho/personalizado}/dados.xlsx"

caminho_excel <- "Automação - Amazon.xlsx"
wb <- openxlsx::loadWorkbook(caminho_excel)
openxlsx::writeData(wb, sheet = 2, dados)
openxlsx::saveWorkbook(wb,caminho_excel, overwrite = T )


