
# caminho do arquivo com urls do whatsapp
path <- "Links_IN/Extração de Dados - Origem Link Whatsapp.xlsx"

# informa lista de urls para baixar
lista_url <- openxlsx::read.xlsx(path,sheet = 1, colNames = T, cols = 1) |>
  dplyr::pull() |>
  stringr::str_squish()

source('~/Projetos/promobuzi/Funcoes_R/detalhes_pechinchou.R')
dados <- detalhes_pechinchou(lista_url)

writexl::write_xlsx(dados, "Links_OUT/links_pechinchou.xlsx")
