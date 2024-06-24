

imagem_produto <- function(img_url,
                           margem = 5,
                           width = 852,
                           height = 850,
                           formato="webp",
                           diretorio=".") {

  image_name <- img_url |>
    urltools::path() |>
    stringr::str_extract("[^/]+(?=\\.[^/.]+$)") |>
    stringr::str_remove( "\\.")

  img <- img_url |>
    magick::image_read() |>
    magick::image_resize(paste0((width - margem), "x", (height - margem)))

  image_info <- magick::image_info(img)
  image_width <- image_info$width
  image_height <- image_info$height

  offset_x <- (width - image_width) / 2
  offset_y <- (height - image_height) / 2

  background <- magick::image_blank(width = width, height = height, color = "white")

  arquivo <- file.path(diretorio, paste0(image_name, ".", formato))

  magick::image_composite(background, img, offset = paste0("+", offset_x, "+", offset_y)) |>
    magick::image_write(path = arquivo, format = formato)

}
