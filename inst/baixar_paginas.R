
baixar_paginas <- function(lista_url = NULL, diretorio = "."){

  if(is.null(diretorio)){
    diretorio <- "data-raw/"
  }

  pagina <- seq_along(lista_url)

  h <-  c(
    `User-Agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:123.0) Gecko/20100101 Firefox/123.0",
    `Accept-Language` = "pt-BR,pt;q=0.8,en-US;q=0.5,en;q=0.3",
    `Accept-Encoding` = "gzip, deflate, br" )

  purrr::walk2(lista_url,pagina , purrr::possibly(~{

    nome_loja <- stringr::str_extract(.x, "(?<=\\/\\/)(?:www\\.)?([^\\.]+)") |>
      stringr::str_replace_all("www.","")

    path <- file.path(diretorio, paste0(nome_loja,"_arquvio_",.y,"_extracao.html"))

    .x |>
      httr2::request() |>
      httr2::req_headers(!!!h)|>
      httr2::req_perform(path = path)


  }, NULL))
}
