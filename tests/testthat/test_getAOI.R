context("getAOI")

test_that("getAOI throws correct errors", {
  expect_error(getAOI(state = '23'), "State not recongized. Full names or abbreviations can be used. Please check spelling.")
  expect_error(getAOI(state= c('CA', 23)), "State not recongized. Full names or abbreviations can be used. Please check spelling.")
  expect_error(getAOI(state = 'CA', clip_unit = list('KMART near UCSB', 10, 10)), "Only 'state' or 'clip_unit' can be used. Set the other to NULL")
  expect_error(getAOI(county = 'Santa Barbara'), "The use of 'county' requires the 'state' parameter be used as well.")
  expect_error(getAOI(), "Requires a 'clip_unit' or 'state' parameter to execute")
  expect_error(getAOI(state = 12), "State must be a character value. Try surrounding in qoutes...")
  expect_error(getAOI(clip_unit = list(37 ,200, 10, 10)), "Longitude must be vector element 2 and between -180 and 180")
  expect_error(getAOI(clip_unit = list(97 ,115, 10, 10)), "Latitude must be vector element 1 and between -90 and 90")
  expect_error(getAOI(state = "CA", county = "Sant Barbara"), "Sant Barbara not a valid county in California.")


  expect_error(getAOI(clip_unit = list(37,10,10)),  cat("A clip_unit with length 3 must be defined by:\n",
                                                           "1. A name (i.e 'UCSB') (character)\n",
                                                           "2. A bound box height (in miles) (numeric)\n",
                                                           "3. A bound box width (in miles) (numeric)"
  ))

  expect_error(getAOI(clip_unit = list(37,10,10, "upperleft")),  cat("A clip_unit with length 4 must be defined by:\n",
                                                                         "1. A latitude (numeric)",
                                                                         "2. A longitude (numeric)\n",
                                                                         "2. A bounding box height (in miles) (numeric)\n",
                                                                         "3. A bounding box width (in miles) (numeric)\n\n",
                                                                         "OR\n\n",
                                                                         "1. A location (character)\n",
                                                                         "2. A bound box height (in miles) (numeric)\n",
                                                                         "3. A bounding box width (in miles) (numeric)\n",
                                                                         "4. A bounding box origin (character)"
))

})


test_that("check AOI routines", {
  one_state <- try(getAOI(state = "Colorado"))
  sp_def <- try(getAOI(clip_unit = one_state))
  rast  = raster::raster(matrix(rnorm(400),20,20), crs = AOI::aoiProj)
  raster::extent(rast) = raster::extent(sp_def)
  ras_def <- try(getAOI(clip_unit = rast) %>% check())
  two_state <- try(getAOI(state = c("AZ", "utah")))

  one_county <- try(getAOI(state = 'TX', county = 'Harris'))
  two_county <- try(getAOI(state = 'California', county = c('Santa Barbara', 'ventura')))

  clip_3   <- try(getAOI(clip_unit = list('KMART near UCSB', 10, 10)))
  clip_4_1 <- try(getAOI(clip_unit = list('University of Alabama', 10, 10, "upperleft")))
  clip_4_2 <- try(getAOI(clip_unit = list(37, -119, 10, 10)))
  clip_5   <- try(getAOI(clip_unit = list(35, -115, 10, 10, "lowerright")) %>% check())
  clip_ll  <- try(getAOI(clip_unit = list(35, -115, 10, 10, "lowerleft")))
  clip_ur  <- try(getAOI(clip_unit = list(35, -115, 10, 10, "upperright")))
  clip_center  <- try(getAOI(clip_unit = list(35, -115, 10, 10, "center")))

  vec = c(one_state, sp_def, two_state, one_county, two_county, clip_3, clip_4_1, clip_4_2, clip_5, clip_ll, clip_ur, clip_center)
  print(!inherits(vec,"try-error"))
  check = !inherits(vec,"try-error")
  expect_true(check)
})
