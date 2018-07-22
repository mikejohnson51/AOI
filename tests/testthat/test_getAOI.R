context("getAOI")

test_that("getAOI throws correct errors", {
  expect_error(getAOI(state = '23'), "State not recongized. Full names or abbreviations can be used. Please check spelling.")
  expect_error(getAOI(state= c('CA', 23)), "State not recongized. Full names or abbreviations can be used. Please check spelling.")
  expect_error(getAOI(state = 'CA', clip = list('KMART near UCSB', 10, 10)), "Only 'state' or 'clip' can be used. Set the other to NULL")
  expect_error(getAOI(county = 'Santa Barbara'), "The use of 'county' requires the 'state' parameter be used as well.")
  expect_error(getAOI(), "Requires a 'clip' or 'state' parameter to execute")
  expect_error(getAOI(state = 12), "State must be a character value. Try surrounding in qoutes...")
  expect_error(getAOI(clip = list(37 ,200, 10, 10)), "Longitude must be vector element 2 and between -180 and 180")
  expect_error(getAOI(clip = list(97 ,115, 10, 10)), "Latitude must be vector element 1 and between -90 and 90")
  expect_error(getAOI(state = "CA", county = "Sant Barbara"), "Sant Barbara not a valid county in California.")


  expect_error(getAOI(clip = list(37,10,10)),  cat("A clip with length 3 must be defined by:\n",
                                                           "1. A name (i.e 'UCSB') (character)\n",
                                                           "2. A bound box height (in miles) (numeric)\n",
                                                           "3. A bound box width (in miles) (numeric)"
  ))

  expect_error(getAOI(clip = list(37,10,10, "upperleft")),  cat("A clip with length 4 must be defined by:\n",
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




