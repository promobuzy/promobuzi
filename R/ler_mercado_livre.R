ler_mercado_livre <- function(arquivos = NULL, diretorio = ".") {

  if(is.null(arquivos)){

    arquivos <- list.files(diretorio, full.names = T) |>
      stringr::str_subset("mercadolivre")

  }

  conteudo <- purrr::map(arquivos, ~xml2::read_html(.x, encoding = "UTF-8"))

  links <- readr::read_lines(paste0(diretorio,"links.txt")) |>
    tibble::as_tibble() |>
    tidyr::separate(value, c("path","link","index"), sep =",", convert = T)

  purrr::map_dfr(seq_along(conteudo), purrr::possibly(~{

    x <- conteudo[[.x]]

    link <- links$link[links$path == arquivos[[.x]] |> stringr::str_extract("[^/]+$")]

    titulo <- xml2::xml_find_first(x, ".//h1") |>
      xml2::xml_text()

    texto_opcional <- xml2::xml_find_first(x, ".//a[@class= 'ui-pdp-promotions-pill-label__target']") |>
      xml2::xml_text()

    if (is.na(texto_opcional)) {

      texto_opcional <- httr2::request(link) |>
        httr2::req_headers(`User-Agent` = "Mozilla/5.0") |>
        httr2::req_perform() |>
        httr2::resp_body_html() |>
        xml2::xml_find_first("//span[@class = 'poly-component__highlight']") |>
        xml2::xml_text(trim = T)
    }

    preco_antigo <- xml2::xml_find_first(x, ".//span[@data-testid='price-part']//span[@class='andes-money-amount__fraction']") |>
      xml2::xml_text() |>
      stringr::str_extract("\\d{1,3}(\\.\\d{3})*(,\\d{2})?")

    preco_novo <- xml2::xml_find_first(x, ".//div[@class='ui-pdp-price__second-line']//span[@data-testid='price-part']") |>
      xml2::xml_text() |>
      stringr::str_extract("\\d{1,3}(\\.\\d{3})*(,\\d{2})?")

    # corrigi preço antigo
    if(preco_antigo == preco_novo){
      preco_antigo <- NA
      }

    parcelamento <- xml2::xml_find_first(x, ".//div[@class='ui-pdp-price__subtitles']") |>
      xml2::xml_text()

    if (is.na(parcelamento)) {

      parcelamento <- httr2::request(link) |>
        httr2::req_headers(`User-Agent` = "Mozilla/5.0") |>
        httr2::req_perform() |>
        httr2::resp_body_html() |>
        xml2::xml_find_first("//span[contains(@class,'poly-price__installments')]") |>
        xml2::xml_text(trim = T)
    }

    entrega <- xml2::xml_find_all(x, "//div[@id='shipping_summary'] | //div[@class= 'ui-pdp-media ui-pdp-shipping ui-pdp-shipping--md mb-12 ui-pdp-color--GREEN']//p[contains(@class, 'GREEN')]") |>
      xml2::xml_text() |>
      unique() |>
      paste(collapse = " ") |>
      (\(texto)dplyr::case_when(
        stringr::str_detect(texto, "[gG]r[áa]ti[sS]") ~ "Frete Grátis",
        TRUE ~ "Frete: Consultar Região"
      ))()

    pagamento <- xml2::xml_find_first(x, ".//span[@class ='ui-pdp-price__second-line__text']") |>
      xml2::xml_text()

    cupom <- httr2::request(link) |>
      httr2::req_headers(`User-Agent` = "Mozilla/5.0") |>
      httr2::req_perform() |>
      httr2::resp_body_html() |>
      xml2::xml_find_first("//span[@class = 'poly-coupon']") |>
      xml2::xml_text(trim = T)


    index <- links$index[links$path == arquivos[[.x]] |> stringr::str_extract("[^/]+$")]

    dados <- tibble::tibble(index = index, titulo, texto_opcional, preco_antigo, preco_novo, pagamento, parcelamento, cupom, entrega, link, loja = "34790")

  }, NULL), .progress = TRUE)
}




