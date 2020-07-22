library(magrittr)

source("scripts/lib/utils.R")

input <- "data-raw/compras-coronavirus.xlsx"
output <- jsonlite::read_json("datapackage.json")$resources[[1]]$path

result <- input %>% 
            read() %>% 
            recode() %>% 
            enrich()

data.table::fwrite(result, file = output, sep = ";", dec = ",", bom = TRUE, na = "NA")
