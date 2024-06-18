
ler_magazine_luiza <- function(arquivos = NULL, diretorio = ".") {

  if(is.null(arquivos)){

    arquivos <- list.files(diretorio, full.names = T) |>
      stringr::str_subset("magazinevoce|magazine|magalu")
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

    titulo <- xml2::xml_find_first(x, ".//h1") |>
      xml2::xml_text()

    texto_opcional <- xml2::xml_find_first(x, ".//div[@data-testid= 'wrapper-badge']//img") |>
      xml2::xml_attr("src") |>
      {\(texto)dplyr::case_when(
        stringr::str_detect(texto,"https://i.mlcdn.com.br/selo-ml/65x50/920ad65a-ccf2-11ee-b5d3-866f14f5ec6c.png") ~ "👀 OFERTA DO DIA",

        stringr::str_detect(texto,"https://i.mlcdn.com.br/selo-ml/65x50/b225b3ba-c1fd-11ee-97a5-02566cc712d2.png") ~ "⚡ Oferta Relâmpago",

        stringr::str_detect(texto,"https://i.mlcdn.com.br/selo-ml/65x50/04c128f0-dd8a-11ee-97a5-02566cc712d2.png") ~ "📺 Viu essa oferta na TV?",

        stringr::str_detect(texto,"https://i.mlcdn.com.br/selo-ml/65x50/e412ff6a-2688-11ee-94bb-de108f8f523f.png") ~ "♨️ Mais Vendido!",

        stringr::str_detect(texto,"https://mvc.mlcdn.com.br/magazinevoce/img/common/black-app-parceiro.png") ~ "🔥 Preço Exclusivo",

        TRUE ~ texto

      )}()


    preco_novo <- xml2::xml_find_first(x, "//p[@data-testid= 'price-value'] ") |>
      xml2::xml_text() |>
      stringr::str_extract("\\d{1,3}(\\.\\d{3})*(,\\d{2})?") |>
      converte_numero()

    preco_antigo <- xml2::xml_find_first(x, "//p[@data-testid= 'price-original'] ") |>
      xml2::xml_text() |>
      stringr::str_extract("\\d{1,3}(\\.\\d{3})*(,\\d{2})?") |>
      converte_numero()

    parcelamento <- xml2::xml_find_first(x, "//p[@data-testid= 'installment'] ") |>
      xml2::xml_text()

    pagamento <- xml2::xml_find_first(x, "//span[@data-testid= 'in-cash'] ") |>
      xml2::xml_text()

    source("~/Projetos/promobuzi/Funcoes_R/func_busca_frete_mglu.R")
    entrega <- tryCatch({
      busca_frete_mglu(conteudo = x) |>
      {\(dados)dplyr::case_when(
        !is.null(dados$customer_cost) && stringr::str_detect(dados$customer_cost, "^0") ~ "Frete Grátis, aproveite!",

        !is.null(dados$politica1) && stringr::str_detect(dados$politica1 , "Retire na") ~ "Retire na loja e não pague frete",

        !is.null(dados$politica2) && stringr::str_detect(dados$politica2 , "Retire na") ~ "Retire na loja e não pague frete",

        TRUE ~  "Frete: Consultar Região"
      )}()
    }, error = function(e) {
      "NA"
    })

    cupom <- NA

    link <- links$link[links$path == arquivos[[.x]] |> stringr::str_extract("[^/]+$")]

    source("~/Projetos/promobuzi/Funcoes_R/modificador_url_concorrente.R")
    urls <- modificador_url_concorrente("magazine",link)

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
      loja = "25828"
      link,
      link_promobuzy = urls[[1]],
      link_qualificados = urls[[2]])


  }, NULL))
}

