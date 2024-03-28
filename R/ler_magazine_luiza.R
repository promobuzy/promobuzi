
ler_magazine_luiza <- function(arquivos = NULL, diretorio = ".") {

  if(is.null(arquivos)){

    arquivos <- list.files(diretorio, full.names = T) |>
      stringr::str_subset("magazinevoce|magazine|magalu")
  }

  conteudo <- purrr::map(arquivos, ~xml2::read_html(.x, encoding = "UTF-8"))

  links <- readr::read_lines(paste0(diretorio,"links.txt")) |>
    tibble::as_tibble() |>
    tidyr::separate(value, c("path","link","index"), sep =",", convert = T)


  purrr::map_dfr(seq_along(conteudo), purrr::possibly(~{

    x <- conteudo[[.x]]

    titulo <- xml2::xml_find_first(x, ".//h1") |>
      xml2::xml_text()

    texto_opcional <- xml2::xml_find_first(x, ".//div[@data-testid= 'wrapper-badge']//img") |>
      xml2::xml_attr("src")

    preco_novo <- xml2::xml_find_first(x, "//p[@data-testid= 'price-value'] ") |>
      xml2::xml_text()

    preco_antigo <- xml2::xml_find_first(x, "//p[@data-testid= 'price-original'] ") |>
      xml2::xml_text()

    parcelamento <- xml2::xml_find_first(x, "//p[@data-testid= 'installment'] ") |>
      xml2::xml_text()

    pagamento <- xml2::xml_find_first(x, "//span[@data-testid= 'in-cash'] ") |>
      xml2::xml_text()

    entrega <- busca_frete_mglu(conteudo = x) |>
      {\(dados)dplyr::case_when(
        !is.null(dados$politica) && stringr::str_detect(dados$politica, "Retire na") ~ "Frete Grátis, retire na loja",
        !is.null(dados$customer_cost) && stringr::str_detect(dados$customer_cost , "^0") ~ "Frete Grátis, aproveite!",
        TRUE ~  "Frete: Consultar Região"
      )}()

    cupom <- NA

    link <- links$link[links$path == arquivos[[.x]] |> stringr::str_extract("[^/]+$")]

    index <- links$index[links$path == arquivos[[.x]] |> stringr::str_extract("[^/]+$")]

    tibble::tibble(index = index, titulo, texto_opcional, preco_antigo, preco_novo, pagamento, parcelamento, cupom, entrega, link, loja = "25828")


  }, NULL), .progress = TRUE)
}

