google_drive_delete_files <- function(){

  id_folder <- jsonlite::read_json("config/configuracoes_googledrive.json") |>
    purrr::pluck(1, "id")

  arquivos <- googledrive::drive_ls(googledrive::as_id(id_folder))

  googledrive::drive_rm(arquivos)

}
