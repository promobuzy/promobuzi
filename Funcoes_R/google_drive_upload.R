google_drive_upload <- function(diretorio = "imagens") {
  # Deleta arquivos antigos
  if (interactive()) {
    if (readline("Deseja deletar arquivos antigos? (s/n)") == "s") {
      message("Deletando arquivos antigos")
      google_drive_delete_files()

    }
  }

    path_completo <- paste0(getwd(), "/", diretorio)

    arquivos <- list.files(path_completo, full.names = T)

    id_folder <- jsonlite::read_json("config/configuracoes_googledrive.json") |>
      purrr::pluck(1, "id")


    purrr::map(arquivos, ~ {
      googledrive::drive_upload(media = .x, path = googledrive::as_id(id_folder)) |>
        googledrive::drive_share(role = "reader", type = "anyone")
    })

}
