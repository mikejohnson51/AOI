zipcodes = USAboundaries::us_zipcodes() %>%
  st_transform(4269)


usethis::use_data(zipcodes)
