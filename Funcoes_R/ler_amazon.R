
ler_amazon <- function(arquivos = NULL, diretorio = ".") {

  if(is.null(arquivos)){

    arquivos <- list.files(diretorio, full.names = T) |>
      stringr::str_subset("amazon|amzn")
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


    titulo <- xml2::xml_find_first(x, "//span[@id='productTitle']") |>
      xml2::xml_text(trim = T)

    depara <- '{
      "Oferta" : "💰 OFERTA",
      "1º mais vendido" : "🥇 1º mais vendido",
      "Com Prime" : "⭐ Exclusiva Amazon Prime",
      "Oferta Prime Day":"⭐ Oferta Prime Day"
    }' |>
      jsonlite::fromJSON()


    texto_opcional <- xml2::xml_find_first(x, ".//span[@id='dealBadgeSupportingText'] | .//div[@id = 'zeitgeistBadge_feature_div']//i") |>
      xml2::xml_text(trim = TRUE) |>
      (\(txt) {
        if (!is.null(depara[[txt]])) {
          depara[[txt]]
        } else {
          txt
        }
      })()

    if(is.null(texto_opcional)){ texto_opcional <- NA}

    regex_preco <- "R\\$\\s*\\d{1,3}(?:\\.?\\d{3})*(?:,\\d{2})?"

    preco_antigo <- xml2::xml_find_first(x, ".//span[contains(@class,'a-price a-text-price') and @data-a-strike='true']") |>
      xml2::xml_text(trim = T) |>
      purrr::possibly(~.[1], otherwise = NA) () |>
      stringr::str_extract(regex_preco) |>
      stringr::str_replace_all("R\\$\\s*", "") |>
      converte_numero()

    ## ERRO PRECO NOVO
    preco_novo <- xml2::xml_find_all(x,  ".//span[@class='a-price aok-align-center reinventPricePriceToPayMargin priceToPay'] | .//div[@class='a-section a-spacing-none aok-align-center']//span[@class='a-offscreen']") |>
      xml2::xml_text(trim = T) |>
      purrr::possibly(~.[1], otherwise = NA)() |>
      stringr::str_extract(regex_preco) |>
      stringr::str_replace_all("R\\$\\s*", "") |>
      converte_numero()

    parcelamento <- xml2::xml_find_first(x, ".//div[@id='installmentCalculator_feature_div']//span[@class ='best-offer-name a-text-bold']") |>
      xml2::xml_text()

    entrega <- xml2::xml_find_first(x, ".//div[@id = 'mir-layout-DELIVERY_BLOCK-slot-PRIMARY_DELIVERY_MESSAGE_LARGE']") |>
      xml2::xml_text(trim = T) |>
      (\(texto)dplyr::case_when(
        stringr::str_detect(texto,"primeiro | 1º") ~ "Frete Grátis - 1º Pedido",
        stringr::str_detect(texto,"Entrega GRÁTIS") ~ "Frete Grátis, aproveite!",
        stringr::str_detect(texto,"Entrega") ~ "Frete: Consultar Região",
      )) ()

    pagamento <- xml2::xml_find_first(x, ".//div[@id='oneTimePaymentPrice_feature_div']//span[@class ='a-size-base a-color-secondary']") |>
      xml2::xml_text()

    # Cupom
    cupom <- xml2::xml_find_first(x, "//label[contains(@id,'couponText')]") |>
      xml2::xml_text(trim = T) |>
      stringr::str_extract("^.*?(?=\\.cx)") |>
      stringr::str_squish()

    if(is.na(cupom)){

      cupom <- xml2::xml_find_first(x, ".//div[@class= 'a-section a-spacing-none a-padding-none accordion-caption']//span[@class='discountText']") |>
        xml2::xml_text() |>
        {\(x) if (!is.na(x)) paste0(x, " ♻️ Comprando c/ recorrência") else "" } ()

    }

    link_img <- xml2::xml_find_first(x, "//div[@id='imgTagWrapperId']//img") |>
      xml2::xml_attr("data-old-hires")

    id_img <- titulo |>
      stringr::str_replace_all("[[:punct:]]|\\+", "") |>
      stringi::stri_trans_general("Latin-ASCII") |>
      stringr::str_squish() |>
      stringr::str_replace_all("[^[:alnum:]-]", "-") |>
      stringr::str_to_lower() |>
      stringr::str_sub(1, 150)


    link <- links$link[links$path == arquivos[[.x]] |> stringr::str_extract("[^/]+$")]

    source("~/Projetos/promobuzi/Funcoes_R/modificador_url_concorrente.R")
    urls <- modificador_url_concorrente("amazon",link)

    index <- links$index[links$path == arquivos[[.x]] |> stringr::str_extract("[^/]+$")] |> as.integer()

    tibble::tibble(
      index = index,
      titulo,
      texto_opcional,
      preco_antigo,
      preco_novo,
      pagamento,
      parcelamento,
      cupom,
      entrega,
      loja = "39836",
      link,
      link_promobuzy = urls[[1]],
      link_qualificados = urls[[2]],
      link_img,
      id_img)

  }, NULL))
}

