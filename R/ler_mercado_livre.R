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

    titulo <- xml2::xml_find_first(x, ".//h1") |>
      xml2::xml_text()

    texto_opcional <- xml2::xml_find_first(x, ".//a[@class= 'ui-pdp-promotions-pill-label__target']") |>
      xml2::xml_text()

    preco_antigo <- xml2::xml_find_first(x, ".//span[@data-testid='price-part']") |>
      xml2::xml_text()

    preco_novo <- xml2::xml_find_first(x, ".//div[@class='ui-pdp-price__second-line']//span[@data-testid='price-part']") |>
      xml2::xml_text()

    parcelamento <- xml2::xml_find_first(x, ".//div[@class='ui-pdp-price__subtitles']") |>
      xml2::xml_text()

    cupom <- NULL

    entrega <- xml2::xml_find_all(x, "//div[@id='shipping_summary'] | //div[@class= 'ui-pdp-media ui-pdp-shipping ui-pdp-shipping--md mb-12 ui-pdp-color--GREEN']//p[contains(@class, 'GREEN')]") |>
      xml2::xml_text() |>
      unique() |>
      paste(collapse = " ") |>
      (\(texto)dplyr::case_when(
        stringr::str_detect(texto, "[gG]r[áa]ti[sS]") ~ "Frete Grátis",
        TRUE ~ paste("Frete", "Consultar Região")
      ))()

    pagamento <- xml2::xml_find_first(x, ".//span[@class ='ui-pdp-price__second-line__text']") |>
      xml2::xml_text()

    link <- links$link[links$path == arquivos[[.x]] |> stringr::str_extract("[^/]+$")]

    index <- links$index[links$path == arquivos[[.x]] |> stringr::str_extract("[^/]+$")]

    dados <- tibble::tibble(index = index, titulo, texto_opcional, preco_antigo, preco_novo, pagamento, parcelamento, cupom, entrega, link, loja = "34790")

  }, NULL), .progress = TRUE)
}




