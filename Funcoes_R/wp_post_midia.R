wp_post_midia <- function(nome_arquivo, diretorio = "imagens") {


  arquivo <- file.path(diretorio, nome_arquivo)

  if (!file.exists(arquivo)) {
    return(NA_character_)
  }

  imagem_bin <- readr::read_file_raw(arquivo)

  headers = c(
    "Content-Disposition" = paste("attachment; filename=", basename(arquivo)),
    "Content-Type" = mime::guess_type(arquivo)
  )

  # URL do endpoint
  url <- "https://promobuzy.com.br/wp-json/wp/v2/media"


  req <- url |>
    httr2::request() |>
    httr2::req_auth_basic(username = Sys.getenv("WP_USER"), password = Sys.getenv("WP_PASSWORD")) |>
    httr2::req_headers(!!!headers) |>
    httr2::req_body_raw(imagem_bin) |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  link_img <- req$media_details$sizes$full$source_url |> as.character()

  return(url)

}
