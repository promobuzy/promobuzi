
baixar_paginas <- function(lista_url = NULL, diretorio = "."){

  if(is.null(diretorio)){
    diretorio <- "logs_automacao/"

  }

  pagina <- seq_along(lista_url)

  arquivos <- list.files(diretorio, full.names = T)

  unlink(arquivos)

  h <-  c(
    `User-Agent` = "Mozilla/5.0 (Linux; Nexus 5 Build/MRA58N)",
    `Accept-Language` = "pt-BR,pt;q=0.8",
    `Accept-Encoding` = "gzip, deflate, br",
    `Accept`= 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
    `Referer`= 'https://www.google.com/')


  pb <- progress::progress_bar$new(
    format = " Processing [:bar] :percent in :elapsed | ETA: :eta",
    total = length(lista_url),
    clear = FALSE,
    width = 60
  )


  message(glue::glue("Baixando {length(lista_url)} paginas da web."))

  purrr::walk2(lista_url,pagina , purrr::possibly(~{

    pb$tick()

    nome_loja <- stringr::str_extract(.x, "(?<=\\/\\/)(?:www\\.)?([^\b]+)(?=\\.[^\\/]+)") |>
      stringr::str_replace_all("www.","")

    ## extrai link absoluto mercado livre
    if(stringr::str_detect(nome_loja, "mercado") == T){
      .c <- .x
      .x <- httr2::request(.x) |>
        httr2::req_headers(!!!h) |>
        httr2::req_perform() |>
        httr2::resp_body_html() |>
        xml2::xml_find_first(".//a[@class = 'poly-component__link poly-component__link--action-link']") |>
        xml2::xml_attr("href")

      if(is.na(.x)){
        .x <- .c
      }

    } else {
      .c <- .x
    }

    nome_arquivo <- paste0(nome_loja,"_arquivo_",.y,"_extracao.html")
    path <- file.path(diretorio, nome_arquivo)
    path_liks <- file.path(diretorio, "links.txt")

    links <- paste(nome_arquivo,.c,.y, sep=",")
    readr::write_lines(links,path_liks, append = T )

    .x |>
      httr2::request() |>
      httr2::req_headers(!!!h)|>
      httr2::req_perform(path = path)



  }, NULL))
}






