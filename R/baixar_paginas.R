
baixar_paginas <- function(lista_url = NULL, diretorio = "."){

  if(is.null(diretorio)){
    diretorio <- "data-raw/"
  }

  pagina <- seq_along(lista_url)

  arquivos <- list.files(diretorio, full.names = T)

  unlink(arquivos)

  Cookie <- readLines("cookie.txt")

  h <-  c(
    `User-Agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:123.0) Gecko/20100101 Firefox/123.0",
    `Accept-Language` = "pt-BR,pt;q=0.8,en-US;q=0.5,en;q=0.3",
    `Accept-Encoding` = "gzip, deflate, br",
    `Cookie` = Cookie)

  purrr::walk2(lista_url,pagina , purrr::possibly(~{

    nome_loja <- stringr::str_extract(.x, "(?<=\\/\\/)(?:www\\.)?([^\\.]+)") |>
      stringr::str_replace_all("www.","")

    nome_arquivo <- paste0(nome_loja,"_arquivo_",.y,"_extracao.html")
    path <- file.path(diretorio, nome_arquivo)
    path_liks <- file.path(diretorio, "links.txt")

    links <- paste(nome_arquivo,.x, sep=",")
    readr::write_lines(links,path_liks, append = T )

     .x |>
      httr2::request() |>
      httr2::req_headers(!!!h)|>
      httr2::req_perform(path = path)


  }, NULL))
}
