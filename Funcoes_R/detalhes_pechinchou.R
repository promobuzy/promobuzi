detalhes_pechinchou <- function(lista_url){

  h <-  c(
    `User-Agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:126.0) Gecko/20100101 Firefox/126.0")


  pb <- progress::progress_bar$new(
    format = " Processing [:bar] :percent in :elapsed | ETA: :eta",
    total = length(lista_url),
    clear = FALSE,
    width = 60
  )


  requisicao_segura <- purrr::possibly(~{
    httr2::request(.x) |>
      httr2::req_headers(!!!h) |>
      httr2::req_perform()
  }, otherwise = NULL)


  purrr::map_dfr(lista_url, ~{

    pb$tick()

    dados <- .x |>
      httr2::request() |>
      httr2::req_perform() |>
      httr2::resp_body_html()

    cupom <- dados |>
      xml2::xml_find_first(".//p[@class='TextCoupon']") |>
      xml2::xml_text()

    preco_antigo <- dados |>
      xml2::xml_find_first(".//p[contains(@class,'styles__OldPrice')]") |>
      xml2::xml_text() |>
      stringr::str_remove_all("R\\$") |>
      stringr::str_squish()

    preco_novo <- dados |>
      xml2::xml_find_first(".//h3") |>
      xml2::xml_text() |>
      stringr::str_remove_all("R\\$") |>
      stringr::str_squish()


    link_afiliado <- dados |>
      xml2::xml_find_first(".//script[@id='__NEXT_DATA__']") |>
      xml2::xml_text() |>
      jsonlite::fromJSON() |>
      purrr::pluck("props", "pageProps", "infos","products", "results","short_url")

    if(is.null(link_afiliado)){

      link_afiliado <- dados |>
        xml2::xml_find_first(".//script[@id='__NEXT_DATA__']") |>
        xml2::xml_text() |>
        jsonlite::fromJSON() |>
        purrr::pluck("props", "pageProps", "promo", "short_url")

    }

    tryCatch({

      link_afiliado <- link_afiliado
      httr2::request() |>
        httr2::req_headers(!!!h) |>
        httr2::req_perform()


    }, error = function(e) {
      link_afiliado <- list(url = link_afiliado)
    })



    produto <- dados |>
      xml2::xml_find_first(".//script[@id='__NEXT_DATA__']") |>
      xml2::xml_text() |>
      jsonlite::fromJSON() |>
      purrr::pluck("props", "pageProps", "promo", "title")

    loja <- dados |>
      xml2::xml_find_first(".//script[@id='__NEXT_DATA__']") |>
      xml2::xml_text() |>
      jsonlite::fromJSON() |>
      purrr::pluck("props", "pageProps", "promo", "store", "name")

    tibble::tibble(
      link_whatsapp = .x,
      loja,
      cupom,
      produto,
      preco_antigo,
      preco_novo,
      link_afiliado$url )

  })
}


