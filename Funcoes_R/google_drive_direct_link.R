google_drive_direct_link <- function(){

  id_folder <- jsonlite::read_json(paste0(getwd(), "/config/configuracoes_googledrive.json")) |>
    purrr::pluck(1, "id")

  drive_imagens <- googledrive::drive_ls(googledrive::as_id(id_folder)) |>
    dplyr::select(name,id) |>
    dplyr::mutate(id_img = stringr::str_extract(name, "^[^.]+(?=\\.)"),
                  direct_link = paste0("https://drive.google.com/uc?id=", id, "&export=download&file=", name)) |>
    dplyr::select(id_img,direct_link) |>
    dplyr::distinct(id_img, .keep_all = T)

  tryCatch({
    path_completo <- paste0(getwd(), "/Links_OUT/dados.xlsx")
    dados <- openxlsx::read.xlsx(path_completo)

    dados |>
      dplyr::left_join(drive_imagens, by = c("id_img" = "id_img")) |>
      openxlsx::write.xlsx(path_completo, asTable = T)

  }, error = function(e) {
    message("Feche o arquivo Excel Dados 😵")
  })
}
