
preparar_para_worldpress <- function(){


  dia_semana <- function() {

    data <- Sys.Date()

    # Obter o dia da semana em português
    dias_semana <- c(
      "DOMINGO",
      "SEGUNDA",
      "TERÇA",
      "QUARTA",
      "QUINTA",
      "SEXTA",
      "SÁBADO"
    )

    return(dias_semana[lubridate::wday(data)])
  }

  dia_semana <- dia_semana()

  conn <- RSQLite::dbConnect(RSQLite::SQLite(), "database.sqlite")

  # prepara para worldpress
  banco_total <- list.files("~/Projetos/promobuzi/Links_IN", full.name = T) |>
    stringr::str_subset("Banco Total") |>
    purrr::map_dfr(purrr::possibly(~{openxlsx::read.xlsx(.x,sheet = 1,colNames = T)},NULL))

  RSQLite::dbWriteTable(conn, "banco_total", banco_total, overwrite = T, )


  dados_automacao <- "~/Projetos/promobuzi/Links_OUT/dados.xlsx" |>
    purrr::map_dfr(purrr::possibly(~{openxlsx::read.xlsx(.x,sheet = 1)},NULL))

  RSQLite::dbWriteTable(conn, "dados_automacao", dados_automacao, overwrite = T)

  dados_concorrentes <- "~/Projetos/promobuzi/Links_OUT/links_pechinchou.xlsx" |>
    purrr::map_dfr(purrr::possibly(~{openxlsx::read.xlsx(.x,sheet = 1)},NULL)) |>
    dplyr::distinct(produto, .keep_all = T)

  RSQLite::dbWriteTable(conn, "dados_concorrentes", dados_concorrentes, overwrite = T)

  query <- "DROP VIEW IF EXISTS produtos"
  RSQLite::dbExecute(conn, query)

  query <-
    glue::glue(
      "
    CREATE VIEW produtos AS
    SELECT
     COALESCE (tot.`Publicado`,-1) AS `Publicado`
    ,COALESCE (tot.`Tipo`,'external') AS `Tipo`
    ,tot.`ID`
    ,COALESCE (tot.`Nome`,aut.titulo) AS `Nome`
    ,COALESCE (tot.`Metadado:.texto-opcional`, aut.texto_opcional) AS `Metadado: texto-opcional`
    ,COALESCE (tot.`Preço`, aut.preco_antigo) AS `Preço`
    ,COALESCE (tot.`Preço.promocional`, aut.preco_novo) AS `Preço promocional`
    ,COALESCE (tot.`Metadado:.parcelamento-descricao`, pagamento) AS `Metadado: parcelamento-descricao`
    ,COALESCE (tot.`Metadado:.parcelamento`, aut.parcelamento) AS `Metadado: parcelamento`
    ,COALESCE (tot.`Metadado:.cupom-1`, aut.cupom) AS `Metadado: cupom-1`
    ,tot.`Metadado:.cupom-1-descricao` AS `Metadado: cupom-1-descricao`
    ,COALESCE (tot.`Metadado:.cupom-1-codigo`, aut.cupom) AS `Metadado: cupom-1-codigo`
    ,COALESCE (tot.`Metadado:.frete`, aut.entrega) AS `Metadado: frete`
    ,tot.`URL.externa` AS `URL externa`
    ,COALESCE (tot.`Metadado:.logotipo`, aut.loja) AS `Metadado: logotipo`
    ,COALESCE (tot.`Categorias`,'{dia_semana}') AS `Categorias`
    ,COALESCE (tot.`Texto.do.botão`,'APROVEITE A OFERTA') AS `Texto do botão`
    ,COALESCE (tot.`Imagens`, aut.direct_link) AS `Imagens`
    ,tot.`Descrição.curta`
    ,aut.link
    ,aut.link_promobuzy
    ,aut.link_qualificados
    FROM dados_automacao aut
    LEFT JOIN banco_total tot on aut.titulo = tot.Nome
  "
    )

  RSQLite::dbExecute(conn, query)

  links <- c('link_promobuzy', 'link_qualificados')

  query <-
  "
  SELECT
   pdr.`Publicado`
  ,pdr.`Tipo`
  ,pdr.`ID`
  ,pdr.`Nome`
  ,pdr.`Metadado: texto-opcional`
  ,COALESCE (pdr.`Preço`, con.preco_antigo) AS `Preço`
  ,COALESCE (pdr.`Preço promocional`, con.preco_novo) AS `Preço promocional`
  ,pdr.`Metadado: parcelamento-descricao`
  ,pdr.`Metadado: parcelamento`
  ,COALESCE (pdr.`Metadado: cupom-1`, con.cupom) AS `Metadado: cupom-1`
  ,pdr.`Metadado: cupom-1-descricao`
  ,COALESCE (pdr.`Metadado: cupom-1-codigo`, con.cupom) AS `Metadado: cupom-1-codigo`
  ,pdr.`Metadado: frete`
  ,COALESCE (pdr.`URL externa`, pdr.LINK_REFERENCIA) AS `URL externa`
  ,pdr.`Metadado: logotipo`
  ,pdr.`Categorias`
  ,pdr.`Texto do botão`
  ,pdr.`Imagens`
  ,pdr.`Descrição.curta`
  FROM produtos pdr
  LEFT JOIN (SELECT
						  produto
						 ,cupom AS cupom
						 ,replace(preco_antigo,',','.') AS preco_antigo
						 ,replace(preco_novo,',','.') AS preco_novo
						 ,loja
						FROM dados_concorrentes
						WHERE cupom IS NOT NULL) con on con.produto = pdr.Nome
  "

 purrr::walk(links, ~{

    query <- query |> stringr::str_replace("LINK_REFERENCIA", .x)

    dados <- suppressWarnings(RSQLite::dbGetQuery(conn, query))

    nome <- .x |>
      stringr::str_extract("[^_]+$")

    arquivo <- glue::glue("~/Projetos/promobuzi/Links_OUT/wp_dados_{nome}.xlsx")

    openxlsx::write.xlsx(file = arquivo, dados, asTable = T)

  })

}






