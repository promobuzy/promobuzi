
ler_amazon <- function(arquivos = NULL, diretorio = ".") {

  if(is.null(arquivos)){

    arquivos <- list.files(diretorio, full.names = T) |>
      stringr::str_subset("amazon|amzn")
  }

  conteudo <- purrr::map(arquivos, ~xml2::read_html(.x, encoding = "UTF-8"))

  links <- readr::read_lines(paste0(diretorio,"links.txt")) |>
    tibble::as_tibble() |>
    tidyr::separate(value, c("path","link","index"), sep =",", convert = T)

  purrr::map_dfr(seq_along(conteudo), purrr::possibly(~{

    x <- conteudo[[.x]]

    titulo <- xml2::xml_find_first(x, "//span[@id='productTitle']") |>
      xml2::xml_text(trim = T)

    texto_opcional <- xml2::xml_find_first(x, ".//span[@id='dealBadgeSupportingText'] | .//div[@id = 'zeitgeistBadge_feature_div']//i") |>
      xml2::xml_text(trim = T)

    preco_antigo <- xml2::xml_find_first(x, ".//span[@class='a-price a-text-price' and @data-a-strike='true']") |>
      xml2::xml_text(trim = T) |>
      purrr::possibly(~.[1], otherwise = NA) () |>
      stringr::str_extract("\\d+,\\d{2}")

    preco_novo <- xml2::xml_find_all(x,  ".//span[@class='a-price aok-align-center reinventPricePriceToPayMargin priceToPay'] | .//div[@class='a-section a-spacing-none aok-align-center']//span[@class='a-offscreen']") |>
      xml2::xml_text(trim = T) |>
      purrr::possibly(~.[1], otherwise = NA) () |>
      stringr::str_extract("\\d+,\\d{2}")


    parcelamento <- xml2::xml_find_first(x, ".//div[@id='installmentCalculator_feature_div']//span[@class ='best-offer-name a-text-bold']") |>
      xml2::xml_text()

    entrega <- xml2::xml_find_first(x, ".//div[@id = 'mir-layout-DELIVERY_BLOCK-slot-PRIMARY_DELIVERY_MESSAGE_LARGE']") |>
      xml2::xml_text(trim = T) |>
      (\(texto)dplyr::case_when(
        stringr::str_detect(texto,"primeiro | 1º") ~ "Frete Grátis - 1° Pedido",
        stringr::str_detect(texto,"Entrega GRÁTIS") ~ "Frete Grátis, aproveite!",
        stringr::str_detect(texto,"Entrega") ~ "Frete: Consultar Região",
      )) ()

    pagamento <- xml2::xml_find_first(x, ".//div[@id='oneTimePaymentPrice_feature_div']//span[@class ='a-size-base a-color-secondary']") |>
      xml2::xml_text()

    cupom <- NA

    link <- links$link[links$path == arquivos[[.x]] |> stringr::str_extract("[^/]+$")]
    index <- links$index[links$path == arquivos[[.x]] |> stringr::str_extract("[^/]+$")]

    tibble::tibble(titulo, texto_opcional, preco_antigo, preco_novo, pagamento, parcelamento, entrega, link, loja = "25827" , index = index )

  }, NULL), .progress = TRUE)
}

