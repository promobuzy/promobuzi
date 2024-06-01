busca_frete_mglu <- function(conteudo, cep = NULL) {

  if(is.null(cep)){
    cep <- "12605530"
  }

 cep <- stringr::str_replace_all(cep,"\\D","")


  url2 <- "https://federation.magazineluiza.com.br/graphql"

  script <- xml2::xml_find_first(conteudo,".//script[@id= '__NEXT_DATA__']") |>
    xml2::xml_text() |>
    jsonlite::fromJSON()

  if(is.null(script)){
    return(NULL)
  }

  json_data <- jsonlite::toJSON(script, pretty = TRUE)

  subcategoryId <-purrr::pluck(script,"props","pageProps","structure","route","subCategoryId")
  height <- purrr::pluck(script,"props","pageProps","data","product","dimensions","height")
  length <- purrr::pluck(script,"props","pageProps","data","product","dimensions","length")
  weight <- purrr::pluck(script,"props","pageProps","data","product","dimensions","weight")
  width <- purrr::pluck(script,"props","pageProps","data","product","dimensions","width")
  price <- purrr::pluck(script,"props","pageProps","data","product","price","fullPrice") |>
    as.double()
  #product_id <- purrr::pluck(script,"props","pageProps","data","product","id")
  categoryId <- toupper(purrr::pluck(script,"query","path4"))
  sellerID <- purrr::pluck(script,"props","pageProps","data","product","seller","id")
  product_id <- purrr::pluck(script,"props","pageProps","data","product","seller","sku")

  json_string <- sprintf(
    '{"operationName": "shippingQuery",
      "query": "query shippingQuery($shippingRequest: ShippingRequest!) {\\n  shipping(shippingRequest: $shippingRequest) {\\n    status\\n    ...shippings\\n    ...estimate\\n    ...estimateError\\n    __typename\\n  }\\n}\\n\\nfragment estimateError on EstimateErrorResponse {\\n  error\\n  status\\n  message\\n  __typename\\n}\\n\\nfragment estimate on EstimateResponse {\\n  disclaimers {\\n    sequence\\n    message\\n    __typename\\n  }\\n  deliveries {\\n    id\\n    items {\\n      bundleComposition {\\n        quantity\\n        sku\\n        __typename\\n      }\\n      gifts {\\n        quantity\\n        sku\\n        __typename\\n      }\\n      quantity\\n      seller {\\n        id\\n        name\\n        sku\\n        __typename\\n      }\\n      type\\n      __typename\\n    }\\n    modalities {\\n      id\\n      type\\n      name\\n      serviceProviders\\n      shippingTime {\\n        unit\\n        value {\\n          min\\n          max\\n          __typename\\n        }\\n        description\\n        disclaimers {\\n          sequence\\n          message\\n          __typename\\n        }\\n        __typename\\n      }\\n      campaigns {\\n        id\\n        name\\n        skus\\n        __typename\\n      }\\n      cost {\\n        customer\\n        operation\\n        __typename\\n      }\\n      zipCodeRestriction\\n      __typename\\n    }\\n    provider {\\n      id\\n      __typename\\n    }\\n    status {\\n      code\\n      message\\n      __typename\\n    }\\n    __typename\\n  }\\n  shippingAddress {\\n    city\\n    district\\n    ibge\\n    latitude\\n    longitude\\n    prefixZipCode\\n    state\\n    street\\n    zipCode\\n    __typename\\n  }\\n  status\\n  __typename\\n}\\n\\nfragment shippings on ShippingResponse {\\n  status\\n  shippings {\\n    id\\n    name\\n    packages {\\n      price\\n      seller\\n      sellerDescription\\n      deliveryTypes {\\n        id\\n        description\\n        type\\n        time\\n        price\\n        __typename\\n      }\\n      __typename\\n    }\\n    __typename\\n  }\\n  __typename\\n}\\n",
      "variables": {
        "shippingRequest": {
          "metadata": {
            "categoryId": "%s",
            "clientId": "",
            "organizationId": "magazine_luiza",
            "pageName": "",
            "partnerId": "0",
            "salesChannelId": "4",
            "sellerId":"%s",
            "subcategoryId": "%s"
          },
          "product": {
            "dimensions": {
              "height": %s,
              "length": %s,
              "weight": %s,
              "width": %s
            },
            "id": "%s",
            "price": %s,
            "quantity": 1,
            "type": "product"
          },
          "zipcode": "%s"
        }
      }
    }', categoryId,sellerID, subcategoryId, height,length,weight,width,product_id,price, cep)

  body_json <- jsonlite::fromJSON(json_string)

  r2 <- url2 |>
    httr2::request() |>
    httr2::req_body_json(body_json) |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  if(is.null(r2$error)){
    dados <- r2$data$shipping$deliveries


    dados <- list(
        prazo = purrr::pluck(dados,1,"modalities",1,"shippingTime","description"),
        customer_cost = purrr::pluck(dados,1,"modalities",1,"cost","customer"),
        politica_unificada = purrr::pluck(dados,1,"modalities",1,"campaigns",1,"name"),
        politica1 = purrr::pluck(dados,1,"modalities",1,"shippingTime","description"),
        politica2 = purrr::pluck(dados,1,"modalities",2,"shippingTime","description")
      )

    return(dados)

  } else {
    stop("Erro na requisição:", r2$error$message)
  }

}
