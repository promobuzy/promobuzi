

make_url_query_woocomerce <- function(base_url, consumer_key, consumer_secret){

  paste0(base_url, "?consumer_key=", consumer_key, "&consumer_secret=", consumer_secret)
}


produtos <- "https://promobuzy.com.br/wp-json/wc/v3/products"
categories <- "https://promobuzy.com.br/wp-json/wc/v3/products/categories"

consumer_key  <- "ck_53bf61fbdab289dc68c156fca321bfbd375b18b3"
consumer_secret <-  "cs_a150b583aa697ea47226d0273339a4884a612d7a"


end_point <- make_url_query_woocomerce(produtos, consumer_key, consumer_secret)

produtos <- end_point |>
  httr2::request() |>
  httr2::req_perform() |>
  httr2::resp_body_json()


produtos[[1]]$date_created


