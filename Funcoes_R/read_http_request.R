parse_http_headers <- function(file_path) {
    # Lê o arquivo
    lines <- readr::read_lines(file_path)

    headers <- lines[-1]

    headers_tibble <- tibble::tibble(raw = headers) |>
      tidyr::separate(raw, into = c("key", "value"), sep = ": ", extra = "merge", fill = "right") |>
      dplyr::mutate(value = stringr::str_trim(value, side = "both"))

    return(headers_tibble)
  }
