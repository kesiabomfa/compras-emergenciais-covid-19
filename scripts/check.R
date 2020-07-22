library(magrittr)

controle <- readr::read_csv2("data-raw/compras-coronavirus-controle.csv", col_types = c("ccnccccnc"), locale = readr::locale(decimal_mark = ",", grouping_mark = "."))

compras_coronavirus <- readr::read_csv2(jsonlite::read_json("datapackage.json")$resources[[1]]$path)

diff_publicacao <- dplyr::anti_join(controle, compras_coronavirus, by = "NUMERO_PROCESSO_COMPRA")

problemas_publicacao <- diff_publicacao %>% 
  dplyr::filter(DIVULGAR == "sim") %>% 
  dplyr::pull(NUMERO_PROCESSO_COMPRA)

if(length(problemas_publicacao) > 0) {
  stop(glue::glue("O processo {problemas_publicacao} não foi inserido no Armazém."))
}

diff_catalogacao <- dplyr::anti_join(compras_coronavirus, controle, by = "NUMERO_PROCESSO_COMPRA")

problemas_catalogacao <- diff_catalogacao %>% 
  dplyr::pull(NUMERO_PROCESSO_COMPRA)

if(length(problemas_catalogacao) > 0) {
  stop(glue::glue("O processo {problemas_catalogacao} não estão presentes no arquivo controle"))
}
