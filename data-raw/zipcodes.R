zipcodes = USAboundaries::us_zipcodes()  |>
  sf::st_transform(4269) |>
  dplyr::select(zipcode) %>%
  dplyr::mutate(lat = sf::st_coordinates(.)[,2],
                lon = sf::st_coordinates(.)[,1]) |>
  sf::st_drop_geometry()

usethis::use_data(zipcodes, overwrite = TRUE)
