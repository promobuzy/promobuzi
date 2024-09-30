

preparar_para_worldpress <- function() {
  conn <- RSQLite::dbConnect(RSQLite::SQLite(), "database.sqlite")

  dia_semana <- function() {
    data <- Sys.Date()

    # Obter o dia da semana em português
    dias_semana <- c("DOMINGO",
                     "SEGUNDA",
                     "TERÇA",
                     "QUARTA",
                     "QUINTA",
                     "SEXTA",
                     "SÁBADO")

    return(dias_semana[lubridate::wday(data)])
  }

  dia_semana <- dia_semana()

  # prepara para worldpress
  banco_total <- list.files("~/Projetos/promobuzi/Links_IN", full.name = T) |>
    stringr::str_subset("Banco Total") |>
    purrr::map_dfr(purrr::possibly( ~ {
      openxlsx::read.xlsx(.x, sheet = 1, colNames = T)
    }, NULL))

  RSQLite::dbWriteTable(conn, "banco_total", banco_total, overwrite = T, )


  dados_automacao <- "~/Projetos/promobuzi/Links_OUT/dados.xlsx" |>
    purrr::map_dfr(purrr::possibly( ~ {
      openxlsx::read.xlsx(.x, sheet = 1)
    }, NULL))

  RSQLite::dbWriteTable(conn, "dados_automacao", dados_automacao, overwrite = T)

  dados_concorrentes <- "~/Projetos/promobuzi/Links_OUT/links_pechinchou.xlsx" |>
    purrr::map_dfr(purrr::possibly( ~ {
      openxlsx::read.xlsx(.x, sheet = 1)
    }, NULL)) |>
    dplyr::distinct(produto, .keep_all = T)

  RSQLite::dbWriteTable(conn, "dados_concorrentes", dados_concorrentes, overwrite = T)


  query <- "DROP TABLE IF EXISTS produtos"
  RSQLite::dbExecute(conn, query)

  query <-
    "
    CREATE TABLE IF NOT EXISTS produtos  (
   `Publicado` TEXT
  ,`Tipo` TEXT
  ,`ID` TEXT
  ,`Nome` TEXT
  ,`Metadado: texto-opcional` TEXT
  ,`Preço` TEXT
  ,`Preço promocional` TEXT
  ,`Metadado: parcelamento-descricao` TEXT
  ,`Metadado: parcelamento` TEXT
  ,`Metadado: cupom-1` TEXT
  ,`Metadado: cupom-1-descricao` TEXT
  ,`Metadado: cupom-1-codigo` TEXT
  ,`Metadado: frete` TEXT
  ,`URL externa` TEXT
  ,`Metadado: logotipo` TEXT
  ,`Categorias` TEXT
  ,`Texto do botão` TEXT
  ,`Imagens` TEXT
  ,`Descrição curta` TEXT
  ,`link` TEXT
  ,`link_promobuzy` TEXT
  ,`link_qualificados` TEXT
)
"
  RSQLite::dbExecute(conn, query)


  query <-
    glue::glue(
      "
      INSERT INTO produtos
   SELECT
      CASE WHEN aut.duplicado = 'Não' THEN -1 ELSE 1 END AS `Publicado`
     ,'external' AS `Tipo`
     ,tot.`ID`
     ,COALESCE (tot.`Nome`,aut.titulo) AS `Nome`
     ,COALESCE (aut.texto_opcional, tot.`Metadado:.texto-opcional`) AS `Metadado: texto-opcional`
     ,COALESCE (aut.preco_antigo, tot.`Preço`) AS `Preço`
     ,COALESCE (aut.preco_novo, tot.`Preço.promocional`) AS `Preço promocional`
     ,COALESCE (aut.pagamento, tot.`Metadado:.parcelamento-descricao`) AS `Metadado: parcelamento-descricao`
     ,COALESCE (aut.parcelamento, tot.`Metadado:.parcelamento`) AS `Metadado: parcelamento`
     ,null AS `Metadado: cupom-1`
     ,null AS `Metadado: cupom-1-descricao`
     ,aut.cupom AS `Metadado: cupom-1-codigo`
     ,COALESCE (aut.entrega, tot.`Metadado:.frete`) AS `Metadado: frete`
     ,tot.`URL.externa` AS `URL externa`
     ,COALESCE (aut.loja, tot.`Metadado:.logotipo`) AS `Metadado: logotipo`
     ,'{dia_semana}' AS `Categorias`
     ,COALESCE (tot.`Texto.do.botão`,'APROVEITE A OFERTA') AS `Texto do botão`
     ,COALESCE (aut.direct_link, tot.`Imagens`) AS `Imagens`
     ,aut.link as `Descrição curta`
     ,aut.link
     ,aut.link_promobuzy
     ,aut.link_qualificados
     FROM dados_automacao aut
     LEFT JOIN banco_total tot on lower(trim(aut.titulo)) = lower(trim(tot.Nome))
    "
    )

  RSQLite::dbExecute(conn, query)

  links <- c('link_promobuzy', 'link_qualificados')

  query <-
    "
  	select
  	 pdr.`Publicado`
  	,pdr.`Tipo`
  	,REPLACE(pdr.`ID`,'.0','') AS `ID`
  	,pdr.`Nome`
  	,pdr.`Metadado: texto-opcional`
  	,COALESCE (con.preco_antigo, pdr.`Preço`) AS `Preço`
  	,COALESCE (con.preco_novo, pdr.`Preço promocional`) as `Preço promocional`
  	,pdr.`Metadado: parcelamento-descricao`
  	,pdr.`Metadado: parcelamento`
  	,pdr.`Metadado: cupom-1` as `Metadado: cupom-1`
  	,pdr.`Metadado: cupom-1-descricao` as `Metadado: cupom-1-descricao`
  	,con.cupom as `Metadado: cupom-1-codigo`
  	,pdr.`Metadado: frete`
  	,COALESCE (pdr.LINK_REFERENCIA, pdr.`URL externa`) as `URL externa`
  	,pdr.`Metadado: logotipo`
  	,pdr.`Categorias`
  	,pdr.`Texto do botão`
  	,pdr.`Imagens`
  	,COALESCE (con.link_afiliado, pdr.`Descrição curta`) AS `Descrição curta`
  	from produtos pdr
  	left join (select
  						  produto as produto
  						 ,cupom as cupom
  						 ,replace(preco_antigo,',','.') as preco_antigo
  						 ,replace(preco_novo,',','.') as preco_novo
  						 ,loja as loja
  						 ,link_afiliado as link_afiliado
  						from dados_concorrentes
  						where cupom is not null) con on lower(trim(con.produto)) = lower(trim(pdr.Nome))
    "
data <- Sys.Date()

  purrr::walk(links, ~{

    query <- query |> stringr::str_replace("LINK_REFERENCIA", .x)

    dados <- suppressWarnings(RSQLite::dbGetQuery(conn, query))

    nome <- .x |>
      stringr::str_extract("[^_]+$")

    arquivo <- glue::glue("~/Projetos/promobuzi/Links_OUT/wp_dados_{nome}_{data}.xlsx")

    openxlsx::write.xlsx(file = arquivo, dados, asTable = T)

    write.csv(dados, glue::glue("~/Projetos/promobuzi/Links_OUT/wp_dados_{nome}_{data}.csv"))


  })

}
