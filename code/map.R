library(XML)
library(dplyr)
library(readr)
library(stringr)
library(sf)
library(ggplot2)
library(leaflet)


readRealTime <- function(url) {
  tmp <- tempfile()
  download.file(url, tmp, mode = "wb")
  x <- xmlToDataFrame(tmp)
  
  timestamp <- x$text[1]
  x <- x[-1,]
  x$timestamp <- timestamp
  x$text <- NULL
  
  x <- x %>% 
    mutate(
      across(c(intensidad:carga, intensidadSat, velocidad), as.numeric),
      across(st_x:st_y, function(x){as.numeric(str_replace(x, ",", "."))}),
      timestamp = as.POSIXct(timestamp, format = "%d/%m/%Y %H:%M:%S"),
      nivelServicio = factor(nivelServicio, c("-1", "0", "1", "2", "3", ""))
    ) 
  
  return(x)
}



url <- "https://informo.madrid.es/informo/tmadrid/pm.xml"
dataRealTime <- readRealTime(url)


df_sf <- st_as_sf(dataRealTime, coords = c("st_x", "st_y"), crs = "+proj=utm +zone=30")
#Projection transformation
sfc = st_transform(df_sf, crs = "+proj=longlat +datum=WGS84")
pal <- colorNumeric(
  palette = 'Dark2',
  domain = sfc$carga
)

pal2 <- colorFactor(
  palette = c("gray60", "#00c300", "#7af160", "#f5d000", "#cc0000", "gray30"),
  domain = sfc$nivelServicio, reverse = F
)
sfc$popup <- paste(
  "Nombre:", sfc$descripcion, "<br>", 
  "Carga:", sfc$carga, "<br>", 
  "Nivel servicio:", sfc$nivelServicio
)


library(mapdeck)
# tiles_url <- "https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}"
# tiles_url <- "https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png"
tiles_url <- "https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}{r}.png"



colores <- tibble(
  nivelServicio = c("0", "1", "2", "3", "-1"),
  color = c("#60d394FF", "#ffd97dFF", "#ee6055FF", "#780116FF", "#6c757dFF")
)

df <- merge(sfc, colores, by = "nivelServicio", all = T)



l1 <- legend_element(
  variables = colores$nivelServicio,
  colours = colores$color,
  colour_type = "fill",
  variable_type = "category"
)
js <- mapdeck_legend(l1)



mapdeck(
  style = mapdeck_style("light"),
  location = c(-3.688236280183302, 40.43574387906006),
  zoom = 11,
) %>%
  add_scatterplot(
    data = df, 
    radius_min_pixels = 2,
    radius = 20, 
    stroke_width = 0,
    # legend = T,
    update_view = F, 
    focus_layer = F,
    radius_max_pixels = 4,
    fill_colour = "color",
    tooltip = "popup",
    legend = js
  )

