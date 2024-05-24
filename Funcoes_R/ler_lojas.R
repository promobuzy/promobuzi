le_lojas <- function(AMZ = 0,
                     ML = 0,
                     MGL = 0,
                     dir_funcoes_R = "~/Projetos/promobuzi/Funcoes_R",
                     dir_output = "~/Projetos/promobuzi/Links_OUT",
                     dir_logs  = '~/Projetos/promobuzi/logs_automacao'){

  arquivos <- list()

  salva_excel <- function(dados,nome_arquivo,diretorio="."){

    path <- file.path(diretorio, nome_arquivo)
    openxlsx::write.xlsx(dados, file = path, asTable = T)
  }

  if(AMZ == 1){
    message(" 📖 Lendo dados da AMAZON")
    source(glue::glue('{dir_funcoes_R}/ler_amazon.R'))
    df <- ler_amazon(diretorio = dir_logs)
    nome_arquivo_amz <- "dados_amazon.xlsx"
    salva_excel(df, nome_arquivo_amz, dir_output)
    message(paste("💾 Dados salvos em ", file.path(dir_output, nome_arquivo_amz)))
    arquivos <- append(arquivos, file.path(dir_output, nome_arquivo_amz))
    rm(df)

  }

  if(ML == 1){
    message(" 📖 Lendo dados MERCADO LIVRE")
    source(glue::glue('{dir_funcoes_R}/ler_mercado_livre.R'))
    df <- ler_mercado_livre(diretorio = dir_logs)
    nome_arquivo_ml <- "dados_mercado_livre.xlsx"
    salva_excel(df, nome_arquivo_ml, dir_output)
    message(paste("💾 Dados salvos em ", file.path(dir_output, nome_arquivo_ml)))
    arquivos <- append(arquivos, file.path(dir_output, nome_arquivo_ml))
    rm(df)
  }


  if(MGL == 1){
    message(" 📖 Lendo dados MAGAZINE LUIZA")
    source(glue::glue('{dir_funcoes_R}/ler_magazine_luiza.R'))
    df <- ler_magazine_luiza(diretorio = dir_logs)
    nome_arquivo_mgl <- "dados_magazine_luiza.xlsx"
    salva_excel(df, nome_arquivo_mgl, dir_output)
    message(paste("💾 Dados salvos em ", file.path(dir_output, nome_arquivo_mgl)))
    arquivos <- append(arquivos, file.path(dir_output, nome_arquivo_mgl))
    rm(df)
  }

  message("Unificando dados...")
  dados_combinados <- arquivos |>
    purrr::map_dfr(~ openxlsx::read.xlsx(.x, colNames= T) |>
                     dplyr::mutate_all(as.character))


  caminho_combined <- file.path(dir_output, "dados.xlsx")
  openxlsx::write.xlsx(dados_combinados, file = caminho_combined, asTable = TRUE)

  message(paste("💾 Base final salva em ", caminho_combined))

}
