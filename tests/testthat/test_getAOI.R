context("getAOI")

state_only <- getAOI(state = "Colorado")
multiple_states <- getAOI(state = c('CA', 'nevada'))
state_county <- getAOI(state = 'California', county = c('Santa Barbara', 'ventura'))
clip_1 <- getAOI(clip_unit = list('KMART near UCSB', 10, 10, 'lowerleft'))

test_that("getAOI throws correct errors", {
  expect_error(getAOI(state = '23'), "State not recongized. Full names or abbreviations can be used. Please check spelling.")
  expect_error(getAOI(state= c('CA', 23)), "State not recongized. Full names or abbreviations can be used. Please check spelling.")
  expect_error(getAOI(state = 'CA', clip_unit = list('KMART near UCSB', 10, 10)), "Only 'state' or 'clip_unit' can be used. Set the other to NULL")
  expect_error(getAOI(county = 'Santa Barbara'), "The use of 'county' requires the 'state' parameter be used as well.")
  expect_error(getAOI(), "Requires a 'clip_unit' or 'state' parameter to execute")
})

test_that("AOI returns type 'S4'", {
  expect_equal(typeof(state_only), "S4")
  expect_equal(typeof(state_county), "S4")
  expect_equal(typeof(clip_1), "S4")
})

