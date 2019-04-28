library(sf)
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggrepel)
library(maps)
library(readxl)
library(tidyxl)

library(neonUtilities)
library(geoNEON) # install_github("NEONscience/NEON-geolocation", subdir = "geoNEON")

get_if_not_exists <- function(url, destfile, overwrite){
  if(!file.exists(destfile) | overwrite){
    download.file(url, destfile)
  }else{
    message(paste0("A local copy of ", url, " already exists on disk"))
  }
}

get_highlights <- function(col_num, col_name){
  # col_num <- 7
  fills <- xlsx_cells(sheet_path) %>%
    dplyr::filter(row >= 2, col == col_num) %>%
    mutate(fill_color = fill_colors[local_format_id]) %>%
    dplyr::select(row, character, fill_color) %>%
    mutate(highlight = case_when(
      !is.na(fill_color) ~ TRUE,
      TRUE ~ FALSE
    ))
  fills$siteID <- col_name
  fills
}

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

saveRDS(neon_lakes, "data/neon_lakes.rds")
# neon_lakes <- readRDS("data/neon_lakes.rds")

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
sheet_path   <- "data/NEON_data_product_status.xlsx"
get_if_not_exists("https://data.neonscience.org/documents/10179/11206/NEON_data_product_status/f82f959f-b53c-44cc-ad2b-70303ac6ddc3",
              sheet_path, overwrite = FALSE)

dt           <- readxl::read_excel(sheet_path)
fill_colors  <- tidyxl::xlsx_formats(sheet_path)$local$fill$patternFill$fgColor$rgb
lake_columns <- data.frame(column_position = match(neon_lakes$siteID, names(dt)),
                           siteID = neon_lakes$siteID, stringsAsFactors = FALSE)
dt           <- dt[,names(dt) %in% c("Name", "Code", "Supplier", neon_lakes$siteID)]
dt           <- tidyr::gather(dt, key = "siteID", value = "year",
                    -Name, -Code, -Supplier)
dt$row       <- rep(2:157, 6)


dt_highlights <- lapply(seq_len(nrow(lake_columns)),
                        function(x) get_highlights(lake_columns$column_position[x],
                                                   lake_columns$siteID[x]))
dt_highlights <- dplyr::bind_rows(dt_highlights)

dt <- left_join(dt, dt_highlights, by = c("siteID", "row"))
dt <- dplyr::filter(dt, !is.na(character) & highlight)
dt <- dplyr::select(dt, Name, siteID, year)
dt <- distinct(dt, siteID, Name, .keep_all = TRUE)
test <- tidyr::spread(dt, siteID, year)

# Name siteID year highlight



# ---- pull some specific data ----
