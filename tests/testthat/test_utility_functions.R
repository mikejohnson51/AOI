context("utilities")

test_that("findLatLong example returns a number", {

  my.location = findLatLong()

  expect_equal(names(my.location), c("lat", "lon"))

  expect(is.numeric(my.location$lat))
  expect(is.numeric(my.location$lon))
})
