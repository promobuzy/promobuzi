

modificador_url_concorrente <- function(loja, url) {
  if (stringr::str_detect(loja, "amazon|amzn")) {

    lapply(c("promobuzy-20", "qualificados-20"), function(tag) {
      urltools::param_set(url, "tag", tag)
    })

    } else if (stringr::str_detect(loja, "magazinevoce|magazine|magalu")) {
      lapply(c("magazinepromobuzy" , "magazinequalificadosbr"), function(tag) {
        parts <- urltools::url_parse(url)
        path_parts <- stringr::str_split(parts$path, "/")[[1]]
        path_parts[1] <- tag
        path <- paste0(path_parts, collapse = "/")
        parts$path <- path
        urltools::url_compose(parts)
      })
    }
}
