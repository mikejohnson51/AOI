context("utility functions")

test_that("aoi_inside...", {
  # r = raster::raster(system.file("external/test.grd", package="raster"))
  lake_tahoe <- aoi_get(x = list("Lake Tahoe, CA", 100, 100))
  CA <- aoi_get(state = "CA")
  SB <- aoi_get(state = "CA", county = "Santa Barbara")

  # Is Lake Tahoe completely inside CA?
  expect_false(aoi_inside(AOI = CA, obj = lake_tahoe, total = T))
  expect_true(aoi_inside(CA, lake_tahoe, total = F))
  expect_true(aoi_inside(CA, SB, total = F))

  expect_true(aoi_inside(CA, SB, total = F))
  expect_true(aoi_inside(AOI = sf::as_Spatial(CA), obj = sf::as_Spatial(SB), total = F))

  expect_false(aoi_inside(AOI = r, obj = SB))
  expect_false(aoi_inside(SB, r))
})

test_that("aoi_buffer", {
  CA <- aoi_get(state = "CA")
  pure_area <- sf::st_area(CA)
  grow <- sf::st_area(aoi_buffer(CA, 10))
  shrink <- sf::st_area(aoi_buffer(CA, -10))

  expect_true(pure_area > shrink)
  expect_true(pure_area < grow)

  ucsb <- aoi_get("UCSB")
  growUCSB_mile <- aoi_buffer(ucsb, 10)
  growUCSB_km <- aoi_buffer(ucsb, 10, km = TRUE)

    expect_true(sf::st_area(growUCSB_mile) > sf::st_area(growUCSB_km))
})


test_that("aoi_get", {

  rev <- geocode_rev("UCSB")

  expect_error(aoi_get(list(10, 10, 10, "upperleft")), NULL)
  expect_error(aoi_get(list(10, 10, 10)), NULL)
  expect_error(aoi_get(10), NULL)

  sfCA <- aoi_get(state = "CA")
  CA <- bbox_get(sfCA)
  CAsf <- aoi_get(x = sfCA)
  CAsp <- aoi_get(x = sf::as_Spatial(sfCA))

  expect_true(identical(round(sf::st_coordinates(CA), 4), round(sf::st_coordinates(CAsf), 4)))
  expect_true(identical(round(sf::st_coordinates(CA), 4), round(sf::st_coordinates(CAsp), 4)))
})
