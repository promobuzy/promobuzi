ler_mercado_livre <- function(arquivos = NULL, diretorio = ".") {

  if(is.null(arquivos)){

    arquivos <- list.files(diretorio, full.names = T) |>
      stringr::str_subset("mercadolivre")

  }

  purrr::map_dfr(arquivos, purrr::possibly(~{

    content <- .x |>
      xml2::read_html(encoding = "UTF-8")

    titulo <- xml2::xml_find_first(content, ".//h1") |>
      xml2::xml_text()

    texto_opcional <- xml2::xml_find_first(content, ".//div[@class= 'ui-pdp-promotions-pill mt-10']") |>
      xml2::xml_text()

    preco_antigo <- xml2::xml_find_first(content, ".//span[@data-testid='price-part']") |>
      xml2::xml_text()

    preco_novo <- xml2::xml_find_first(content, ".//div[@class='ui-pdp-price__second-line']//span[@data-testid='price-part']") |>
      xml2::xml_text()

    parcelamento <- xml2::xml_find_first(content, ".//p[@id='pricing_price_subtitle']") |>
      xml2::xml_text()

    desconto <- xml2::xml_find_first(content, ".//div[@class='ui-pdp-price__second-line']//span[@class='ui-pdp-price__second-line__label ui-pdp-color--GREEN ui-pdp-size--MEDIUM']") |>
      xml2::xml_text()

    entrega <- xml2::xml_find_first(content, ".//p[@class='ui-pdp-color--GREEN ui-pdp-family--SEMIBOLD ui-pdp-media__title']") |>
      xml2::xml_text()

    dados <- tibble::tibble(loja = "Mercado Livre", titulo, texto_opcional, preco_novo, preco_antigo, parcelamento, desconto, entrega)

  }, NULL), .progress = TRUE)
}


