library(sf)
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggrepel)
library(maps)
library(readxl)

library(neonUtilities)
library(geoNEON) # install_github("NEONscience/NEON-geolocation", subdir = "geoNEON")

# ---- pull lake locations ----

states <- sf::st_as_sf(maps::map("state", plot = FALSE, fill = TRUE))

neon_lakes  <- data.frame( # excluding `TOOK` in Alaska
  siteID = c("CRAM", "SUGG", "BARC", "PRPO", "LIRO", "PRLA"),
    stringsAsFactors = FALSE) %>%
  geoNEON::def.extr.geo.os("siteID") %>%
  mutate(api.decimalLatitude = as.numeric(api.decimalLatitude),
         api.decimalLongitude = as.numeric(api.decimalLongitude)) %>%
  sf::st_as_sf(coords = c("api.decimalLongitude", "api.decimalLatitude"),
               crs = 4326)

site_labels <- data.frame(siteID = neon_lakes$siteID,
                          sf::st_coordinates(neon_lakes),
                          stringsAsFactors = FALSE)

ggplot() +
  geom_sf(data = states) +
  geom_sf(data = neon_lakes, aes(color = Value.for.DURATION), alpha = 0.6) +
  geom_text_repel(data = site_labels, aes(x = X, y = Y, label = siteID)) +
  theme_void() + coord_sf(datum = NA) +
  labs(color = '')

# ---- pull data availability table ----
sheet_path <- "data/NEON_data_product_status.xlsx"
download.file("https://data.neonscience.org/documents/10179/11206/NEON_data_product_status/f82f959f-b53c-44cc-ad2b-70303ac6ddc3",
              sheet_path)
dt <- readxl::read_excel(sheet_path)
dt <- dt[,names(dt) %in% c("Name", "Code", "Supplier", neon_lakes$siteID)]
dt <- tidyr::gather(dt, key = "siteID", value = "year",
                    -Name, -Code, -Supplier)

fill_colors <- tidyxl::xlsx_formats(
  "data/NEON_data_product_status.xlsx")$local$fill$patternFill$fgColor$rgb

get_highlights <- function(col_num){
  # col_num <- 7
  fills <- xlsx_cells(sheet_path) %>%
    dplyr::filter(row >= 2, col == col_num) %>%
    mutate(fill_color = fill_colors[local_format_id]) %>%
    dplyr::select(row, character, fill_color) %>%
    mutate(highlight = case_when(
      !is.na(fill_color) ~ TRUE,
      TRUE ~ FALSE
    ))
}


# Name siteID year highlight



# ---- pull some specific data ----
