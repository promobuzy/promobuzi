detalhes_pechinchou <- function(lista_url){

  h <-  c(
    `User-Agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:126.0) Gecko/20100101 Firefox/126.0")


  pb <- progress::progress_bar$new(
    format = " Processing [:bar] :percent in :elapsed | ETA: :eta",
    total = length(lista_url),
    clear = FALSE,
    width = 60
  )


  purrr::map_dfr(lista_url, purrr::possibly(~{

    pb$tick()

    dados <- .x |>
      httr2::request() |>
      httr2::req_perform() |>
      httr2::resp_body_html()

    cupom <- dados |>
      xml2::xml_find_first(".//p[@class='TextCoupon']") |>
      xml2::xml_text()

    link_afiliado <- dados |>
      xml2::xml_find_first(".//script[@id='__NEXT_DATA__']") |>
      xml2::xml_text() |>
      jsonlite::fromJSON() |>
      purrr::pluck("props", "pageProps", "promo", "short_url")

    produto <- dados |>
      xml2::xml_find_first(".//script[@id='__NEXT_DATA__']") |>
      xml2::xml_text() |>
      jsonlite::fromJSON() |>
      purrr::pluck("props", "pageProps", "promo", "title")

    tibble::tibble(link_whatsapp = .x, cupom, produto, link_afiliado)

  }, NULL))
}
