library(XML)
library(dplyr)
library(readr)
library(stringr)

connectSQL <- function() {
  require(RMariaDB)
  require(DBI)
  drv <- dbDriver("MariaDB")
  con <- dbConnect(
    drv = drv,
    username = 
    password = 
    host = 
    port = "3306",
    dbname = "MadTraffic"
  )
  
  return(con)
}


loadToDB <- function(file, con) {
  data <- read_csv2(file, show_col_types = FALSE)
  DBI::dbWriteTable(con, "traffic_data", data)
}


files <- list.files("data/historico/", full.names = T, pattern = "zip")
con <- connectSQL()
purrr::map(files, loadToDB, con = con)
dbDisconnect(con)

