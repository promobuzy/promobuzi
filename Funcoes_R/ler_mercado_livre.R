ler_mercado_livre <- function(arquivos = NULL, diretorio = ".") {

  if(is.null(arquivos)){

    arquivos <- list.files(diretorio, full.names = T) |>
      stringr::str_subset("mercadolivre")

  }

  converte_numero <- function(numero){
    numero <- stringr::str_replace_all(numero, stringr::fixed("."), "")
    numero <- stringr::str_replace_all(numero, stringr::fixed(","), ".")
    numero <- as.numeric(numero)
    numero <- format(numero, nsmall = 2, big.mark = ".", decimal.mark = ",")
    return(numero)
  }

  qtt_arquivos <- length(arquivos)

  # Criar a barra de progresso
  pb <- progress::progress_bar$new(
    format = "  Processing [:bar] :percent in :elapsed | ETA: :eta",
    total = qtt_arquivos,
    clear = FALSE,
    width = 60
  )

  message(glue::glue("Etapa 1/2 - Lendo Conteúdo HTML de {qtt_arquivos} arquivos"))

  conteudo <- purrr::map(arquivos, function(file) {
    pb$tick()  # Atualizar a barra de progresso
    xml2::read_html(file, encoding = "UTF-8")
  })


  links <- readr::read_lines(paste0(diretorio,"/links.txt")) |>
    tibble::as_tibble() |>
    tidyr::separate(value, c("path","link","index"), sep =",", convert = T)

  # Criar a barra de progresso
  pb <- progress::progress_bar$new(
    format = "  Processing [:bar] :percent in :elapsed | ETA: :eta",
    total = qtt_arquivos,
    clear = FALSE,
    width = 60
  )

  message("Etapa 2/2 - Extraíndo Conteúdo")

  purrr::map_dfr(seq_along(conteudo), purrr::possibly(~{
    pb$tick()

    x <- conteudo[[.x]]

    link <- links$link[links$path == arquivos[[.x]] |> stringr::str_extract("[^/]+$")]

    titulo <- xml2::xml_find_first(x, ".//h1") |>
      xml2::xml_text()

    depara = '{
        "MAIS VENDIDO":"♨️ Mais Vendido!",
        "Oferta do Dia":"👀 OFERTA DO DIA",
        "RECOMENDADO":"🤝 Recomendado",
        "OFERTA RELÁMPAGO": "⚡ Oferta Relâmpago"
    }' |>
      jsonlite::fromJSON()

    texto_opcional <- xml2::xml_find_first(x, ".//a[@class= 'ui-pdp-promotions-pill-label__target']") |>
      xml2::xml_text() |>
      (\ (txt) if(!is.na(depara[txt])) depara[txt] else txt )() |>
      purrr::pluck(1)

    if (is.na(texto_opcional) || is.null(texto_opcional) ) {

      texto_opcional <- httr2::request(link) |>
        httr2::req_headers(`User-Agent` = "Mozilla/5.0") |>
        httr2::req_perform() |>
        httr2::resp_body_html() |>
        xml2::xml_find_first("//span[@class = 'poly-component__highlight']") |>
        xml2::xml_text(trim = T) |>
        (\ (txt) if(!is.na(depara[txt]))  depara[txt] else txt )() |>
        purrr::pluck(1)
    }

    parcelamento <- xml2::xml_find_first(x, ".//div[@class='ui-pdp-price__subtitles']") |>
      xml2::xml_text()

    if (is.null(parcelamento) || is.na(parcelamento) || !stringr::str_detect(parcelamento,"R\\$")) {

      parcelamento <- httr2::request(link) |>
        httr2::req_headers(`User-Agent` = "Mozilla/5.0") |>
        httr2::req_perform() |>
        httr2::resp_body_html() |>
        xml2::xml_find_first("//span[contains(@class,'poly-price__installments')]") |>
        xml2::xml_text(trim = T)
    }

    regex_preco <- "\\bR\\$\\s*\\d{1,3}(?:\\.?\\d{3})*(?:,\\d{2})?\\b"

    if(!stringr::str_detect(parcelamento,"R\\$")) {

      preco_novo <- httr2::request(link) |>
        httr2::req_headers(`User-Agent` = "Mozilla/5.0") |>
        httr2::req_perform() |>
        httr2::resp_body_html() |>
        xml2::xml_find_first("//div[@class='poly-price__current']//span[contains(@class,'andes-money-amount')]") |>
        xml2::xml_text(trim = T) |>
        stringr::str_extract(regex_preco) |>
        stringr::str_replace_all("R\\$\\s*", "") |>
        converte_numero()

      preco_antigo <- httr2::request(link) |>
        httr2::req_headers(`User-Agent` = "Mozilla/5.0") |>
        httr2::req_perform() |>
        httr2::resp_body_html() |>
        xml2::xml_find_first("//div[@class='poly-component__price']//s[contains(@class,'andes-money-amount andes-money-amount--previous')]") |>
        xml2::xml_text(trim = T) |>
        stringr::str_extract(regex_preco) |>
        stringr::str_replace_all("R\\$\\s*", "")|>
        converte_numero()

    } else {

      preco_antigo <- xml2::xml_find_first(x, ".//span[@data-testid='price-part']") |>
        xml2::xml_text() |>
        stringr::str_extract(regex_preco) |>
        stringr::str_replace_all("R\\$\\s*", "") |>
        converte_numero()


      preco_novo <- xml2::xml_find_first(x, ".//div[@class='ui-pdp-price__second-line']//span[@data-testid='price-part']") |>
        xml2::xml_text() |>
        stringr::str_extract(regex_preco) |>
        stringr::str_replace_all("R\\$\\s*", "") |>
        converte_numero()
    }


    # corrigi preço antigo
    if (is.na(preco_antigo) || is.na(preco_novo)) {

    } else if (preco_antigo == preco_novo) {
      preco_antigo <- NA
    }


    entrega <- xml2::xml_find_all(x, "//div[@id='shipping_summary'] | //div[@class= 'ui-pdp-media ui-pdp-shipping ui-pdp-shipping--md mb-12 ui-pdp-color--GREEN']//p[contains(@class, 'GREEN')]") |>
      xml2::xml_text() |>
      unique() |>
      paste(collapse = " ") |>
      (\(texto)dplyr::case_when(
        stringr::str_detect(texto, "[gG]r[áa]ti[sS]") ~ "Frete Grátis, aproveite!",
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


    index <- links$index[links$path == arquivos[[.x]] |> stringr::str_extract("[^/]+$")] |> as.integer()

    dados <- tibble::tibble(
      index = index,
      titulo,
      texto_opcional,
      preco_antigo,
      preco_novo,
      pagamento,
      parcelamento,
      cupom,
      entrega,
      loja = "34790",
      link,
      link_promobuzy = NA,
      link_qualificados = NA)

  }, NULL))
}




