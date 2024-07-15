wp_direct_link <- function(img_format="webp", diretorio = "imagens") {

  tryCatch({

    path_completo <- paste0(getwd(), "/Links_OUT/dados.xlsx")
    dados <- openxlsx::read.xlsx(path_completo)

    source('~/Projetos/promobuzi/Funcoes_R/wp_post_midia.R')
    dados |>
      dplyr::mutate(direct_link = dplyr::if_else( duplicado =="Não", purrr::map2_chr(paste0(id_img,".",img_format),diretorio,purrr::possibly(~{ wp_post_midia(.x,.y)  }, NA_character_)), NA_character_) ) |>
      openxlsx::write.xlsx(path_completo, asTable = T)

  }, error = function(e) {

    message(e$message)

  })
}


