
# informa lista de urls para baixar, pode vir de uma planilha em excel.

<<<<<<< HEAD
lista_url <- openxlsx::read.xlsx("Automação - Amazon.xlsx",sheet = 2, colNames = F) |>
=======
lista <- openxlsx::read.xlsx("Captação de Ofertas - Promobuzy - v1.xlsx",sheet = 1, colNames = F) |>
>>>>>>> 9784941ff8897f2fde96cf94c3cc6bfba6013504
  dplyr::pull()


lista_url <- c("https://mercadolivre.com/sec/2XZRNp6")

# informa diretorio onde dados devem ser salvos.
diretorio <- "data-raw/"

## Baixa Paginas da Web.
baixar_paginas(lista_url = lista_url, diretorio = diretorio)

# Lista os arquivos baixados.
arquivos <- list.files(diretorio, full.names = T)

# Lê arquivos, para cada loja existe um função especifica para ler dados da pagina
dados_amz <- ler_amazon(diretorio = diretorio)
dados_mcl <- ler_mercado_livre(diretorio = diretorio)
dados_mgl <- ler_magazine_luiza(diretorio = diretorio)

# Unifica data frames
<<<<<<< HEAD
dados <- dplyr::bind_rows(dados_amz,dados_mcl,dados_mgl)
=======
dados <- dplyr::bind_rows(dados_amz, dados_mcl)
>>>>>>> 9784941ff8897f2fde96cf94c3cc6bfba6013504

# Salva dados em formato xlsx na pata raiz, pode informar o diretorio completo "{seu/caminho/personalizado}/dados.xlsx"

caminho_excel <- "Captação de Ofertas - Promobuzy - v1.xlsx"
wb <- openxlsx::loadWorkbook(caminho_excel)
openxlsx::writeData(wb, sheet = 2, dados)
openxlsx::saveWorkbook(wb,caminho_excel, overwrite = T )


