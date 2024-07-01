

modificador_url_concorrente <- function(loja, url) {

  tryCatch({

    if (stringr::str_detect(stringr::str_to_lower(loja), "amazon|amzn")) {

      lapply(c("promobuzy-20", "qualificados-20"), function(tag) {
        urltools::param_set(url, "tag", tag)

      })

    } else if (stringr::str_detect(stringr::str_to_lower(loja),"magazinevoce|magazine|magalu")) {

      lapply(c("magazinepromobuzy" , "magazinequalificadosbr"), function(tag) {


        qtt_path <- urltools::url_parse(url) |>
          dplyr::pull(path) |>
          stringr::str_split("/") |>
          purrr::map_int(~{length(.x)})


        if(qtt_path == 1){

          long_url <- url |>
            httr2::request() |>
            httr2::req_headers(`User-Agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:126.0) Gecko/20100101 Firefox/126.0") |>
            httr2::req_perform()

          url <- long_url$url

        }

        parts <- urltools::url_parse(url)
        path_parts <- stringr::str_split(parts$path, "/")[[1]]
        path_parts[1] <- tag
        path <- paste0(path_parts, collapse = "/")
        parts$path <- path
        urltools::url_compose(parts)

      })

    }  else if (stringr::str_detect(stringr::str_to_lower(loja), "mercadolivre")) {

      lapply(c("promobuzy","qualificados"), function(tag) {

        if(tag =="promobuzy"){
          path <- "~/Projetos/promobuzi/cookies/ML_promobuzy_cookie.txt"
        }
        else {
          path <- "~/Projetos/promobuzi/cookies/ML_qualificados_fc20240528150632_cookie.txt"
          tag <- "promobuzy"
        }
        source("~/Projetos/promobuzi/Funcoes_R/read_http_request.R")

        link <- "https://www.mercadolivre.com.br/affiliate-program/api/affiliates/v1/createUrls"

        cookie <- parse_http_headers(path) |>
          dplyr::filter(key == "Cookie") |>
          dplyr::pull(value)

        csrf_token <- parse_http_headers(path) |>
          dplyr::filter(key == "x-csrf-token") |>
          dplyr::pull(value)

        User_Agent <- parse_http_headers(path) |>
          dplyr::filter(key == "User-Agent") |>
          dplyr::pull(value)

        body <- list(urls = list(url), tag  = tag)

        headers <- c(
          "User-Agent" = User_Agent,
          "Content-Type" = "application/json;charset=utf-8",
          "x-csrf-token" = csrf_token,
          Cookie = cookie
        )

        dados <- link |>
          httr2::request() |>
          httr2::req_headers(!!!headers) |>
          httr2::req_body_json(body) |>
          httr2::req_perform() |>
          httr2::resp_body_json()

        dados$urls[[1]]$short_url[1]
      })
    }
  }, error = function(e) {
    message("Erro: ", e)
  })

}



#urls <- "https://www.mercadolivre.com.br/g-tech-gp400-branco-medidor-de-presso-arterial-digital/p/MLB19380860#polycard_client=storefronts&wid=MLB3345740523&sid=storefronts&type=product&tracking_id=ebff8bf1-859e-496c-b707-ed2455715859&source=eshops"

#modificador_url_concorrente("mercadolivre", urls)



