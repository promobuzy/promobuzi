verifica_duplicado <- function(base_ofertas){

  arquivos <- list.files("~/Projetos/promobuzi/Links_IN", full.name = T) |>
    stringr::str_subset("Banco Total")

  produtos_publicados <- purrr::map_dfr(arquivos, ~{openxlsx::read.xlsx(.x,sheet = 1)}) |>
    dplyr::select(Nome) |>
    dplyr::distinct() |>
    dplyr::pull()

  base_ofertas |>
    dplyr::mutate(duplicado = ifelse(titulo %in% produtos_publicados, "Sim", "Não"))

}
