

make_url_query_woocomerce <- function(base_url, consumer_key, consumer_secret){

  paste0(base_url, "?consumer_key=", consumer_key, "&consumer_secret=", consumer_secret)
}


produtos <- "https://promobuzy.com.br/wp-json/wc/v3/products"
categories <- "https://promobuzy.com.br/wp-json/wc/v3/products/categories"

consumer_key  <- ""
consumer_secret <-  ""


end_point <- make_url_query_woocomerce(produtos, consumer_key, consumer_secret)

produtos <- end_point |>
  httr2::request() |>
  httr2::req_perform() |>
  httr2::resp_body_json()


produtos[[1]]$date_created


