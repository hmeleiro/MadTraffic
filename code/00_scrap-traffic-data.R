library(dplyr)
library(stringr)
library(rvest)

downloadFile <- function(url) {
  file <- str_remove_all(url, ".+/|-trans.+")
  file <- paste0("data/historico/", file, ".zip")
  download.file(url, file)
}

url <- "https://datos.madrid.es/portal/site/egob/menuitem.c05c1f754a33a9fbe4b2e4b284f1a5a0/?vgnextoid=33cb30c367e78410VgnVCM1000000b205a0aRCRD&vgnextchannel=374512b9ace9f310VgnVCM100000171f5a0aRCRD&vgnextfmt=default"
urls <- read_html(url) %>% html_elements(".asociada-list .asociada-link") %>% html_attr("href")
urls <- paste0("https://datos.madrid.es", urls[str_detect(urls, "zip")])

purrr::map(urls, downloadFile)
