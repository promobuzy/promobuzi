
ler_amazon <- function(arquivos = NULL, diretorio = ".") {

  if(is.null(arquivos)){

    arquivos <- list.files(diretorio, full.names = T) |>
      stringr::str_subset("amazon|amzn")
  }

  purrr::map_dfr(arquivos, purrr::possibly(~{

    content <- .x |>
      xml2::read_html(encoding = "UTF-8")

    titulo <- xml2::xml_find_first(content, "//span[@id='productTitle']") |>
      xml2::xml_text(trim = T)

    texto_opcional <- xml2::xml_find_first(content, ".//span[@id='dealBadgeSupportingText'] | //div[@id = 'zeitgeistBadge_feature_div']//i") |>
      xml2::xml_text(trim = T)

    preco_novo <- xml2::xml_find_all(content, "//span[@class='a-price aok-align-center reinventPricePriceToPayMargin priceToPay']") |>
      xml2::xml_text(trim = T) |>
      purrr::possibly(~.[1], otherwise = NA)()

    preco_antigo <- xml2::xml_find_all(content, "//div[@id='corePriceDisplay_desktop_feature_div']//span[contains(@class, 'aok-offscreen')]") |>
      xml2::xml_text(trim = T) |>
      purrr::possibly(~.[2], otherwise = NA)()

    parcelamento <- xml2::xml_find_first(content, "//div[@id='installmentCalculator_feature_div']//span[@class ='best-offer-name a-text-bold']") |>
      xml2::xml_text()

    desconto <- xml2::xml_find_first(content, "//div[@id='oneTimePaymentPrice_feature_div']//span[@class ='a-size-base a-color-secondary']") |>
      xml2::xml_text()

    entrega <- xml2::xml_find_first(content, ".//div[@id = 'mir-layout-DELIVERY_BLOCK-slot-PRIMARY_DELIVERY_MESSAGE_LARGE']") |>
      xml2::xml_text(trim = T)

    tibble::tibble(loja = "Amazon", titulo, texto_opcional, preco_novo, preco_antigo, parcelamento, desconto, entrega)

  }, NULL), .progress = TRUE)
}





