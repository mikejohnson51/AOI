context("geocode and geocode_rev")


test_that("check geocoding routines", {
  df <- geocode("UCSB", full = FALSE)
  df.full <- geocode("UCSB", full = T)
  point <- geocode("UCSB", pt = TRUE)
  bb <- geocode("UCSB", bb = TRUE)
  point3 <- geocode(location = c("UCSB", "Goleta", "Stearns Wharf"))

  bb2 <- geocode(c("UCSB", "Goleta", "Stearns Wharf"), all = TRUE)

  # Does geocode return a lat / long values that are numeric?
  expect_true(length(df) == 5)
  expect_true(is.numeric(df$lat))
  expect_true(is.numeric(df$lon))

  # Does turning on 'full' add details?
  expect_true(length(df.full) > 2)

  # Does tuning on point create a POINT geometry (sf)
  expect_true(all(sf::st_geometry_type(point) == "POINT"))

  # Does tuning on bb create a POLYGON geometry (sf)
  expect_true(sf::st_geometry_type(bb) == "POLYGON")

  # Does adding 3 input create three rows of data?
  expect_true(nrow(point3) == 3)

  # Do multiple queries and pt=T generate points?
  expect_true(all(sf::st_geometry_type(bb2$pt) == "POINT"))

  # Do multiple queries and bb=T produce a bounding box?
  expect_true(all(sf::st_geometry_type(bb2$bb) == "POLYGON"))
})


test_that("geocodeAOI throws correct errors", {
  # Make sure geocode does not process numeric inputs
  expect_error(geocode(37), "\nInput location is not a place name. \nYou might be looking for reverse geocodeing.\nTry: AOI::geocode_rev")

  # Make sure unfindable locations return NA values but dont break the routine
  bad <- geocode(location = "TweedleDee_TweedleDumb")

  expect_true(is.na(bad$lat))

  expect_true(is.na(bad$lon))
})

test_that("reverse geocoding", {
   osm = geocode_rev(x = c(38,-115))
   esri = geocode_rev(x = c(38,-115), method = "esri")
   ucsb =  geocode_rev("UCSB")

   expect_true("place_id" %in% names(osm))
   expect_true("Match_addr" %in% names(esri))
   expect_true("Match_addr" %in% names(esri))
   expect_equal(ucsb$amenity, 'University of California, Santa Barbara')
})


test_that("event geocoding...", {
  den <- geocode(event = "Denver", pt = TRUE)
  #brexit <- suppressMessages(geocode_wiki(event = "Brexit"))
  harvey <- geocode_wiki(event = "Hurricane Harvey")
  force_null <- geocode_wiki(event = "XYZmikeZYX")

  expect_null(force_null)

  noaa <- geocode_wiki("NOAA", pt = TRUE)

  expect_true(nrow(harvey) > 1)

  expect_true(sf::st_geometry_type(den) == "POINT")
  expect_true(sf::st_geometry_type(noaa) == "POINT")
})


test_that("zipcodes...", {
  many <- geocode(zipcode = c(80526, 80906))
  single <- geocode(zipcode = c(93117))
  points <- geocode(zipcode = 93117, pt = T)
  bb <- geocode(zipcode = c(93117, 80906), bb = T)

  expect_error(geocode(zipcode = c("93016"), pt = T))
  expect_warning(geocode(zipcode = c("93016", "93117"), pt = T))

  expect_true(nrow(many) == 2)
  expect_true(nrow(single) == 1)
  expect_true(sf::st_geometry_type(points) == "POINT")
})
