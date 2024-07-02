

imagem_produto <- function(img_url,
                           img_name = NULL,
                           border = 5,
                           width = 852,
                           height = 850,
                           format="webp",
                           kep.all = F,
                           diretorio=".") {

  if(kep.all == F){

    list.files(diretorio, full.names = T) |>
      unlink()
  }

  if(is.null(img_name)){
    image_name <- img_url |>
      urltools::path() |>
      stringr::str_extract("[^/]+(?=\\.[^/.]+$)") |>
      stringr::str_remove( "\\.")
  } else {
    image_name <- img_name
  }

  kern  <- matrix(c(
    -1, -1, -1, -1, -1,
    -1,  2,  2,  2, -1,
    -1,  2,  10000,  2, -1,
    -1,  2,  2,  2, -1,
    -1, -1, -1, -1, -1), nrow = 5, ncol = 5)

  kern <- kern / sum(abs(kern))

  img <- img_url |>
    magick::image_read() |>
    magick::image_resize(paste0((width - border), "x", (height - border))) |>
    magick::image_enhance() #|>
    #magick::image_convolve(kern) |>
    #magick::image_modulate(brightness = 100, saturation = 100, hue = 100) |>
    #magick::image_border(border_color, paste0(border_size, "x", border_size))


  image_info <- magick::image_info(img)
  image_width <- image_info$width
  image_height <- image_info$height

  offset_x <- (width - image_width) / 2
  offset_y <- (height - image_height) / 2

  background <- magick::image_blank(width = width, height = height, color = "white")

  arquivo <- file.path(diretorio, paste0(image_name, ".", formato))

  magick::image_composite(background, img, offset = paste0("+", offset_x, "+", offset_y)) |>
    magick::image_write(path = arquivo, format = format)

}


#imagem_produto(img_name = "Liquidificador-mondial",
#               img_url = "https://a-static.mlcdn.com.br/800x560/garrafa-termica-tramontina-1l-exata/magazineluiza/234987400/77b20740bf1cf70647c163bd5c9ef5b1.jpg",
#               border = 20,
#               diretorio ="imagens")

#magick::image_read("77b20740bf1cf70647c163bd5c9ef5b1.webp")
#magick::image_read("https://a-static.mlcdn.com.br/800x560/smart-tv-55-4k-led-tcl-55p635-va-wi-fi-bluetooth-hdr-google-assistente-3-hdmi-1-usb/magazineluiza/235509300/7b06db02a0678a23dbc3c399547983cd.jpg")


