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

    if(nrow(df) != 0){
    nome_arquivo_amz <- "dados_amazon.xlsx"
    salva_excel(df, nome_arquivo_amz, dir_output)
    message(paste("💾 Dados salvos em ", file.path(dir_output, nome_arquivo_amz)))
    arquivos <- append(arquivos, file.path(dir_output, nome_arquivo_amz))
    rm(df)

    }
  }

  if(ML == 1){
    message(" 📖 Lendo dados MERCADO LIVRE")
    source(glue::glue('{dir_funcoes_R}/ler_mercado_livre.R'))
    df <- ler_mercado_livre(diretorio = dir_logs)

    if(nrow(df) != 0){
      nome_arquivo_ml <- "dados_mercado_livre.xlsx"
      salva_excel(df, nome_arquivo_ml, dir_output)
      message(paste("💾 Dados salvos em ", file.path(dir_output, nome_arquivo_ml)))
      arquivos <- append(arquivos, file.path(dir_output, nome_arquivo_ml))
      rm(df)

    }
  }

  if(MGL == 1){
    message(" 📖 Lendo dados MAGAZINE LUIZA")
    source(glue::glue('{dir_funcoes_R}/ler_magazine_luiza.R'))
    df <- ler_magazine_luiza(diretorio = dir_logs)

    if(nrow(df) != 0){
    nome_arquivo_mgl <- "dados_magazine_luiza.xlsx"
    salva_excel(df, nome_arquivo_mgl, dir_output)
    message(paste("💾 Dados salvos em ", file.path(dir_output, nome_arquivo_mgl)))
    arquivos <- append(arquivos, file.path(dir_output, nome_arquivo_mgl))
    rm(df)

    }
  }

  message("Unificando dados...")
  dados_combinados <- arquivos |>
    purrr::map_dfr(~ openxlsx::read.xlsx(.x, colNames= T) |>
                     dplyr::mutate_all(as.character))

  message("verificando duplicados...")
  source(glue::glue('{dir_funcoes_R}/verifica_duplicado.R'))
  dados_combinados <- verifica_duplicado(dados_combinados)

  caminho_combinado <- file.path(dir_output, "dados.xlsx")
  openxlsx::write.xlsx(dados_combinados, file = caminho_combinado, asTable = T)

  message(paste("💾 Base salva em ", caminho_combinado))

  # perguntar se poder fazer as imagens
  if (interactive()) {
    if (readline("Deseja criar as imagens dos produtos? (s/n)") == "s") {
      message("Criando imagens dos produtos...")
      source(glue::glue('{dir_funcoes_R}/imagem_produto.R'))

      link_img <- dados_combinados |>
        dplyr::filter(duplicado == "Não" & link_img != "") |>
        dplyr::pull(link_img)


      pb <- progress::progress_bar$new(
        format = "  Processing [:bar] :percent in :elapsed | ETA: :eta",
        total = length(link_img),
        clear = FALSE,
        width = 60
      )

      purrr::walk(link_img[1:10], purrr::possibly( ~ {

        pb$tick()

        imagem_produto(.x, diretorio = "imagens", margem = 100)

      }, NULL))


      message("Gravando caminho das imagens...")
      path_imagens <- "~/Projetos/promobuzi/imagens"
      id_images_feitas <- list.files(path_imagens) |>
        stringr::str_extract("^[^.]+")

      path_completo <- normalizePath(path_imagens) |>
        paste0("\\")

      dados_combinados <- dados_combinados |>
        dplyr::mutate(path_img = ifelse(id_img %in% id_images_feitas,
                                        paste0("file:///",path_completo, paste0(id_img, ".webp")),
                                        NA_character_))

      caminho_combinado <- file.path(dir_output, "dados_completo.xlsx")
      openxlsx::write.xlsx(dados_combinados, file = caminho_combinado, asTable = T)

      message(paste("💾 Base final salva em ", caminho_combinado))

    }
  }
}
