

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

          h <-  c(
            `User-Agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:126.0) Gecko/20100101 Firefox/126.0",
            `Referer` = 'https://www.google.com/'
          )

          long_url <- url |>
            httr2::request() |>
            httr2::req_headers(!!!h) |>
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

      lapply(c("promobuzy","fc20240528150632"), function(tag) {


        if(tag =="promobuzy"){
          path <- "~/Projetos/promobuzi/cookies/ML_promobuzy_cookie.txt"
        }
        else {
          path <- "~/Projetos/promobuzi/cookies/ML_qualificados_fc20240528150632_cookie.txt"
          tag <- "promobuzy"
        }

        source("~/Projetos/promobuzi/Funcoes_R/read_http_request.R")
        api <- "https://www.mercadolivre.com.br/affiliate-program/api/affiliates/v1/createUrls"

        cookie <- parse_http_headers(path) |>
          dplyr::filter(key == "Cookie") |>
          dplyr::pull(value)

        csrf_token <- parse_http_headers(path) |>
          dplyr::filter(key == "x-csrf-token") |>
          dplyr::pull(value)

        User_Agent <- parse_http_headers(path) |>
          dplyr::filter(key == "User-Agent") |>
          dplyr::pull(value)

        url <- httr2::request(url) |>
          httr2::req_headers(`User-Agent` = User_Agent) |>
          httr2::req_perform() |>
          httr2::resp_body_html() |>
          xml2::xml_find_first(".//a[@class = 'poly-component__link poly-component__link--action-link']") |>
          xml2::xml_attr("href")


        body <- list(urls = list(url), tag  = tag)

        headers <- c(
          "User-Agent" = User_Agent,
          "Content-Type" = "application/json;charset=utf-8",
          "x-csrf-token" = csrf_token,
          Cookie = cookie
        )

        if((!is.null(url) && !is.na(url))){

          dados <- api |>
            httr2::request() |>
            httr2::req_headers(!!!headers) |>
            httr2::req_body_json(body) |>
            httr2::req_perform() |>
            httr2::resp_body_json()

        } else {

          dados <- list(urls = list(list(message = "URL inválida")))
        }

        if (!is.null(dados$urls[[1]]$short_url[1])){
          dados$urls[[1]]$short_url[1]
        } else {
          dados$urls[[1]]$message
        }

      })

    }
  }, error = function(e) {
    message("Erro: ", e)
  })

}



#urls <- "https://www.mercadolivre.com.br/social/pechinchou?matt_tool=89815958&forceInApp=true&ref=BGMP2BgK9U85mlmCJgTJh6MSs7HVibFQfNigkIqRvz8jkmKA8d8eZl0UDNZMJ7dLlr%2F7mqF3vYjXUEr8gAKkuHvvt5toDjeFms74vWyDPm4wSmBI25Lwh7eBi5GbUdOtw4gFhO%2BmBEFItv6EGvynSYdUvaTo%2BgJ%2BoUk1E3pyRkp2J2AUtf9AB%2FBIubLn%2FxL%2BjwRQA04%3D"
#modificador_url_concorrente("mercadolivre", urls)



