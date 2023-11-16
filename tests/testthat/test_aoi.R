context("aoi functions")

test_that("aoi_get errors...", {
  expect_error(aoi_get(state = "CA", x = "UCSB"))

  expect_error( aoi_get(state = 10) )

  expect_error( aoi_get(state = "TweedleDee") )

  expect_error( aoi_get(county = "Santa Barbara") )

  expect_error( aoi_get(state = NULL, x = NULL) )
})

test_that("aoi_get & getFiat & getClip & defineClip", {

  FIP = aoi_get(fip  = "08011")
  expect_equal(FIP$name, "Bent")

  expect_error(aoi_get(fip = "1234"))

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

  brazil4 <- aoi_get(country = "076")
  expect_true(brazil4$name == "Brazil")

  south <- aoi_get(state = "south")
  expect_true(nrow(south) == 16)

  africa <- aoi_get(country = "Africa")
  expect_true(nrow(africa) == 52)

  expect_error(
    aoi_get(country = "BRAAAAAAA"),
    "No country found"
  )

  expect_error(aoi_get(state = "CA", county = "Dallas"))

  conus <- aoi_get(state = "conus")
  expect_true(nrow(conus) == 49)

  conus_all <- aoi_get(state = "all")
  expect_true(nrow(conus_all) == 51)

  conus_u <- aoi_get(state = "conus", union = TRUE)
  expect_true(nrow(conus_u) == 1)

  f <- system.file("ex/elev.tif", package="terra")
  r <- terra::rast(f)

   AOIr <- aoi_get(x = r) %>%
    st_transform(terra::crs(r)) %>%
    bbox_coords()

  expect_true(terra::ext(r)[1] == AOIr$xmin, 0)
  expect_true(terra::ext(r)[2] == AOIr$xmax, 0)
  expect_true(terra::ext(r)[3] == AOIr$ymin, 0)
  expect_true(terra::ext(r)[4] == AOIr$ymax, 0)

  fname <- system.file("shape/nc.shp", package = "sf")
  nc <- sf::read_sf(fname)

  sf_obj <- aoi_get(nc)
  sp_obj <- aoi_get(x= sf::as_Spatial(nc))

  expect_true(identical(sf_obj, sp_obj))

  d1 <- geocode("UCSB")
  expect_true(d1$request == "UCSB")

  d2 <- aoi_ext("UCSB", wh = 10)
  d3 <- aoi_ext("UCSB", wh = c(10, 10))
  expect_true(identical(d2, d3))

  aoi_ext("UCSB", bbox = TRUE)

  aoi_ext("UCSB")


  tmp = aoi_ext(xy = c(-119, 37)) %>%
    sf::st_coordinates()

  expect_true(any(tmp != -119))

  tmp =aoi_ext(xy = c(-119, 37), crs = 5070) %>%
    sf::st_coordinates()

  expect_true(all(tmp != -119))

  expect_true(identical(aoi_ext("UCSB", wh = 10), aoi_ext("UCSB", wh = c(10,10))))
  expect_true(!identical(aoi_ext("UCSB", wh = 10), aoi_ext("UCSB", wh = c(100,10))))

  expect_true(sf::st_geometry_type(aoi_ext("UCSB", bbox = TRUE)) == "POINT")
  expect_true(sf::st_geometry_type(aoi_ext("UCSB", wh = 10, bbox = TRUE)) ==  "POLYGON")

  cali_mex <- aoi_get(state = "CA", country = "MX")
  cali_county_mex <- aoi_get(state = "CA", county = "all", country = "MX")

  expect_true(all(cali_mex$NAME %in% c("California", "Mexico")))
  expect_true(nrow(cali_county_mex) == 59)

  expect_error(geocode("UCSB", pt = T, bb = T))


})



test_that("aoi_describe errors...", {

  x = aoi_describe(geocode("Fort Collins", bbox = T))
  expect_true(is.null(x))

  x = aoi_describe(AOI = geocode("Fort Collins", pt = TRUE))
  expect_true(is.null(x))
})


test_that("aoi_map errors...", {
 x = geocode("Fort Collins", bbox = TRUE)
 xx = aoi_map(AOI = x)
 expect_true(inherits(xx, "sf"))
 xx = aoi_map(AOI = x, returnMap = TRUE)
 expect_true(inherits(xx, "leaflet"))
})
