google_drive_auth <- function(diretorio="imagens"){

  message("Autenticando no Google Drive")

  # Auteenticação
  googledrive::drive_auth()

  info_diretorio <- googledrive::drive_get(diretorio)

  if (nrow(info_diretorio) == 0) {
    info_diretorio <- googledrive::drive_mkdir(diretorio)
  }
  info_diretorio <- info_diretorio |>
    dplyr::select(id, name) |>
    jsonlite::toJSON()

  path <- file.path(paste0(getwd(),"/config/configuracoes_googledrive.json"))
  write(info_diretorio, file = path)

}
