
ler_magazine_luiza <- function(arquivos = NULL, diretorio = ".") {

  if(is.null(arquivos)){

    arquivos <- list.files(diretorio, full.names = T) |>
      stringr::str_subset("magazinevoce|magazine")
  }

  purrr::map_dfr(arquivos, purrr::possibly(~{

    content <- .x |>
      xml2::read_html(encoding = "UTF-8")

    titulo <- xml2::xml_find_first(content, ".//h1") |>
      xml2::xml_text()

    texto_opcional <- NA

    preco_novo <- xml2::xml_find_first(content, "//p[@data-testid= 'price-value'] ") |>
      xml2::xml_text()

    preco_antigo <- xml2::xml_find_first(content, "//p[@data-testid= 'price-original'] ") |>
      xml2::xml_text()

    parcelamento <- xml2::xml_find_first(content, "//p[@data-testid= 'installment'] ") |>
      xml2::xml_text()

    desconto <- xml2::xml_find_first(content, "//span[@class= 'sc-hYmls fnoFMk'] ") |>
      xml2::xml_text()

    entrega <- busca_frete_mglu(content) |>
      {\(dados) paste("Frete", "|", dados[[1]]$modalities[[1]]$cost$customer, "|", dados[[1]]$modalities[[1]]$shippingTime$description)} ()

    dados <- tibble::tibble(loja = "Magazine Luiza", titulo, texto_opcional, preco_novo, preco_antigo, parcelamento, desconto, entrega)


  }, NULL), .progress = TRUE)
}

