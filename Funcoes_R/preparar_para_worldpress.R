
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


  chaves <- c(
    "publicado",
    "id",
    "tipo",
    "custom_URI",
    "nome",
    "metadado_texto_opcional",
    "preco",
    "preco_promocional",
    "pagamento",
    "metadado_parcelamento",
    "metadado_cupom_1",
    "metadado_cupom_1_descricao",
    "metadado_cupom_1_codigo",
    "metadado_frete",
    "URL_externa",
    "metadado_logotipo",
    "categorias",
    "texto_do_botao",
    "imagens",
    "descricao_curta",
    "link_promobuzy",
    "link_qualificados",
    "index"
  )
  # prepara para worldpress

  banco_total <- list.files("~/Projetos/promobuzi/Links_IN", full.name = T) |>
    stringr::str_subset("Banco Total") |>
    purrr::map_dfr(purrr::possibly(~{openxlsx::read.xlsx(.x,sheet = 1,colNames = T)},NULL))

  dados_automacao <- "~/Projetos/promobuzi/Links_OUT/dados.xlsx" |>
    purrr::map_dfr(purrr::possibly(~{openxlsx::read.xlsx(.x,sheet = 1)},NULL))


  dados_concorrentes <- "~/Projetos/promobuzi/Links_OUT/links_pechinchou.xlsx" |>
    purrr::map_dfr(purrr::possibly(~{openxlsx::read.xlsx(.x,sheet = 1)},NULL)) |>
    dplyr::distinct(produto, .keep_all = T)


  ref_concorrentes <- function(coluna, filtro_chave){
    coluna <- dplyr::sym(coluna)

    dados_concorrentes |>
      dplyr::filter(produto == filtro_chave ) |>
      dplyr::select(!!coluna) |>
      dplyr::pull()
  }


  campos <- c("preco_antigo", "preco_novo", "cupom")

  dados_automacao <- dados_automacao |>
    dplyr::rowwise() |>
    dplyr::mutate(dplyr::across(dplyr::all_of(campos), ~{
      novo_valor <- ref_concorrentes(dplyr::cur_column(), titulo)
      if (length(novo_valor) == 0) .x else novo_valor
    })) |>
    dplyr::ungroup() |>
    dplyr::left_join(banco_total, by = c("titulo" = "Nome"))


  dados <- dados_automacao |>
    dplyr::mutate(
      publicado = dplyr::coalesce(Publicado, "-1"),
      id = dplyr::coalesce(as.character(ID), NA_character_),
      tipo = dplyr::coalesce(Tipo,"external"),
      custom_URI = dplyr::coalesce(as.character(`Custom.URI`),NA_character_),
      nome = titulo,
      metadado_texto_opcional = dplyr::coalesce(as.character(`Metadado:.texto-opcional`), as.character(texto_opcional)),
      preco = dplyr::coalesce(as.character(preco_antigo), as.character(`Preço`)),
      preco_promocional = dplyr::coalesce(as.character(`Preço.promocional`), as.character(preco_novo)),
      pagamento = dplyr::coalesce(as.character(PAGAMENTO),as.character(pagamento)),
      metadado_parcelamento = dplyr::coalesce(as.character(`Metadado:.parcelamento`), as.character(parcelamento)),
      metadado_cupom_1 = dplyr::coalesce(as.character(`Metadado:.cupom-1`),as.character(cupom)),
      metadado_cupom_1_descricao = dplyr::coalesce(as.character(`Metadado:.cupom-1-descricao`),NA_character_),
      metadado_cupom_1_codigo = dplyr::coalesce(as.character(`Metadado:.cupom-1-codigo`),NA_character_),
      metadado_frete = dplyr::coalesce(as.character(`Metadado:.frete`),as.character(entrega)),
      URL_externa = dplyr::coalesce(as.character(`URL.externa`),as.character(link)),
      metadado_logotipo = dplyr::coalesce(as.character(`Metadado:.logotipo`),as.character(loja)),
      categorias = dplyr::coalesce(as.character(Categorias), dia_semana()),
      texto_do_botao = dplyr::coalesce(as.character(`Texto.do.botão`),NA_character_),
      imagens = dplyr::coalesce(as.character(Imagens),as.character(direct_link)),
      descricao_curta = dplyr::coalesce(as.character(Descrição.curta), NA_character_),
      link_promobuzy = link_promobuzy,
      link_qualificados = link_qualificados,
      index = index
    )|>
    dplyr::select(all_of(chaves)) |>
    openxlsx::write.xlsx("~/Projetos/promobuzi/Links_OUT/wp_dados.xlsx", asTable = T)


}






