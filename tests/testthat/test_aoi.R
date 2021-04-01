context("aoi functions")

test_that("aoi_get errors...", {
  expect_error(
    aoi_get(state = "CA", x = "UCSB"),
    "Only 'state' or 'x' can be used. Set the other to NULL"
  )

  expect_error(
    aoi_get(state = 10),
    "State must be a character value."
  )

  expect_error(
    aoi_get(state = "TweedleDee"),
    "State not recongized. Full names, regions, or abbreviations can be used."
  )

  expect_error(
    aoi_get(county = "Santa Barbara"),
    "The use of 'county' requires a 'state' parameter."
  )

  expect_error(
    aoi_get(state = NULL, x = NULL),
    "Requires a 'x' or 'state' parameter to execute."
  )
})

test_that("aoi_get & getFiat & getClip & defineClip", {
  CA <- aoi_get(state = "CA")
  expect_true(CA$state_abbr == "CA")

  SB <- aoi_get(state = "CA", county = "Santa Barbara")
  expect_true(SB$name == "Santa Barbara")

  ALL <- aoi_get(state = "CA", county = "all")
  expect_true(NROW(ALL) == 58)

  brazil <- aoi_get(country = "Brazil")
  expect_true(brazil$name == "Brazil")

  brazil2 <- aoi_get(country = "BR")
  expect_true(brazil2$name == "Brazil")

  brazil3 <- aoi_get(country = "BRA")
  expect_true(brazil3$name == "Brazil")

  south <- aoi_get(state = "south")
  expect_true(nrow(south) == 16)

  africa <- aoi_get(country = "Africa")
  expect_true(nrow(africa) == 51)

  expect_error(
    aoi_get(country = "BRAAAAAAA"),
    "No country found"
  )

  expect_error(
    aoi_get(state = "CA", county = "Dallas"),
    "Dallas not a valid county in California."
  )

  conus <- aoi_get(state = "conus")
  expect_true(NROW(conus) == 49)

  conus_all <- aoi_get(state = "all")
  expect_true(NROW(conus_all) == 52)

  conus_u <- aoi_get(state = "conus", union = TRUE)
  expect_true(NROW(conus_u) == 1)

  # r = raster::raster(system.file("external/test.grd",
  #                                package="raster"))
  AOIr <- aoi_get(r) %>%
    st_transform(r@crs) %>%
    bbox_coords()
  expect_true(raster::extent(r)[1] == round(AOIr$xmin, 0))
  expect_true(raster::extent(r)[2] == round(AOIr$xmax, 0))
  expect_true(raster::extent(r)[3] == round(AOIr$ymin, 0))
  expect_true(raster::extent(r)[4] == round(AOIr$ymax, 0))

  fname <- system.file("shape/nc.shp", package = "sf")
  nc <- sf::read_sf(fname)

  sf_obj <- aoi_get(nc)
  sp_obj <- aoi_get(sf::as_Spatial(nc))

  expect_true(identical(sf_obj, sp_obj))

  d1 <- aoi_get("UCSB")
  expect_true(d1$request == "UCSB")

  d2 <- aoi_get(list("UCSB", 10, 10))
  d3 <- aoi_get(list("UCSB", 10, 10, center = "center"))
  expect_true(identical(d2, d3))

  dul <- aoi_get(list("UCSB", 10, 10, center = "upperleft"))
  dll <- aoi_get(list("UCSB", 10, 10, center = "lowerleft"))
  dur <- aoi_get(list("UCSB", 10, 10, center = "upperright"))
  dlr <- aoi_get(list("UCSB", 10, 10, center = "lowerright"))

  expect_false(identical(dul, dll))
  expect_false(identical(dul, dur))
  expect_false(identical(dul, dlr))

  num <- aoi_get(list(37, -119, 10, 10))
  num2 <- aoi_get(list(37, -119, 10, 10, "center"))
  expect_true(sf::st_geometry_type(num) == "POLYGON")
  expect_true(identical(num, num2))

  expect_error(
    aoi_get(list(899, -119, 10, 10)),
    "Latitude must be vector element 1 and between -90 and 90"
  )
  expect_error(
    aoi_get(list(-899, -119, 10, 10)),
    "Latitude must be vector element 1 and between -90 and 90"
  )

  expect_error(
    aoi_get(list(39, 190, 10, 10)),
    "Longitude must be vector element 2 and between -180 and 180"
  )

  expect_error(
    aoi_get(list(39, -190, 10, 10)),
    "Longitude must be vector element 2 and between -180 and 180"
  )

  cali_mex <- aoi_get(state = "CA", country = "MX")
  cali_county_mex <- aoi_get(state = "CA", county = "all", country = "MX")

  expect_true(all(cali_mex$NAME %in% c("California", "Mexico")))
  expect_true(nrow(cali_county_mex) == 59)

  expect_error(geocode("UCSB", pt = T, bb = T), "Only pt, bb, or all can be TRUE. Leave others as FALSE")
})
