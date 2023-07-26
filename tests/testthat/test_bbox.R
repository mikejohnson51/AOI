context("bbox functions")

test_that("bbox_get works as expected...", {
  yy <- bbox_get(c(37, 38, -120, -119))
  expect_true(sf::st_geometry_type(yy) == "POLYGON")

  yy2 <- aoi_get(state = "CA") %>% bbox_get()
  expect_true(sf::st_geometry_type(yy2) == "POLYGON")

  r <- raster::raster(system.file("external/test.grd", package = "raster"))
  yy3 <- bbox_get(r)
  expect_true(sf::st_geometry_type(yy3) == "POLYGON")
})


test_that("bbox_get and bbox_coords work as expected...", {
  A <- aoi_get("UCSB")
  bbsf <- bbox_get(A)
  bbsf_vec <- bbox_coords(A)
  expect_true(sf::st_geometry_type(bbsf) == "POLYGON")
  expect_true(length(bbsf_vec) == 4)

  A <- sf::as_Spatial(A)
  bbsp <- bbox_get(A)
  bbsp_vec <- bbox_coords(x = A)
  expect_true(sf::st_geometry_type(bbsp) == "POLYGON")
  expect_true(length(bbsp_vec) == 4)

  bbr <- bbox_get(r)
  bbr_vec <- bbox_coords(r)
  expect_true(sf::st_geometry_type(bbr) == "POLYGON")
  expect_true(length(bbr_vec) == 4)


  yy <- bbox_get("37, 38, -120, -119")
  yy1 <- bbox_get(c(37, 38, -120, -119))
  expect_identical(yy,yy1)
})
