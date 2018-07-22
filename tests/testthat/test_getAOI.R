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


  expect_error(getAOI(clip = list(37,10,10)),  paste0("A clip with length 3 must be defined by:\n",
                                                           "1. A name (i.e 'UCSB') (character)\n",
                                                           "2. A bound box height (in miles) (numeric)\n",
                                                           "3. A bound box width (in miles) (numeric)"
  ), fixed = TRUE)

  expect_error(getAOI(clip = list(37,10,10, "upperleft")),  paste0("A clip with length 4 must be defined by:\n",
                                                                         "1. A latitude (numeric)",
                                                                         "2. A longitude (numeric)\n",
                                                                         "2. A bounding box height (in miles) (numeric)\n",
                                                                         "3. A bounding box width (in miles) (numeric)\n\n",
                                                                         "OR\n\n",
                                                                         "1. A location (character)\n",
                                                                         "2. A bound box height (in miles) (numeric)\n",
                                                                         "3. A bounding box width (in miles) (numeric)\n",
                                                                         "4. A bounding box origin (character)"
), fixed = TRUE)

})


test_that("check AOI routines", {
  map       <- check(AOI = NULL)
  one_state <- getAOI(state = "Colorado")
  sp_def    <- getAOI(clip = one_state)
  map2      <- check(sp_def)
  rast      <- raster::raster(matrix(rnorm(100),10,10), crs = AOI::aoiProj)
  raster::extent(rast) <- raster::extent(sp_def)
  ras_def   <- getAOI(clip = rast)
  two_state <- getAOI(state = c("AZ", "utah"))

  one_county <- getAOI(state = 'TX', county = 'Harris')
  two_county <- getAOI(state = 'California', county = c('Santa Barbara', 'ventura'))

  vec = c(any(class(map) == "leaflet"),
          any(class(map2) == "leaflet"),
          length(one_state) == 1,
          class(rast) == "RasterLayer",
          class(ras_def) == "SpatialPolygons",
          class(sp_def) == "SpatialPolygons",
          length(two_state) == 2,
          length(one_county) ==1,
          length(two_county) == 2)

  rm(map)
  rm(one_state)
  rm(sp_def)
  rm(map2)
  rm(rast)
  rm(ras_def)
  rm(two_state)
  rm(one_county)
  rm(two_county)

  print(all(vec))
  check = all(vec)
  expect_true(check)
})



test_that("check clip origin routines", {

clip_c   <- getAOI(clip = list(35, -115, 10, 10, "center"))@bbox
clip_lr  <- getAOI(clip = list(35, -115, 10, 10, "lowerright"))@bbox
clip_ll  <- getAOI(clip = list(35, -115, 10, 10, "lowerleft"))@bbox
clip_ur  <- getAOI(clip = list(35, -115, 10, 10, "upperright"))@bbox
clip_ul  <- getAOI(clip = list(35, -115, 10, 10, "upperleft"))@bbox

vec = c(

  !all(clip_c==clip_lr),
  !all(clip_c==clip_ll),
  !all(clip_c==clip_ur),
  !all(clip_c==clip_ul),

  !all(clip_ul==clip_ur),
  !all(clip_ul==clip_lr),
  !all(clip_ul==clip_ll),

  !all(clip_ur==clip_lr),
  !all(clip_ur==clip_ll),

  !all(clip_ll==clip_lr))

rm(clip_c)
rm(clip_lr)
rm(clip_ll)
rm(clip_ul)

print(all(vec))
check = all(vec)
expect_true(check)
})



test_that("check external routines", {

  clip_counties_all <-  getAOI(state = "NY", county = "all")
  state.bb          <-  getAOI(state = "CA", bb = TRUE)
  #clip_4            <-  getAOI(clip = list("UCSB", 10,10, "lowerleft"), sf = TRUE)
  #clip_sf           <-  getAOI(clip = list("UCSB", 10,10), sf = TRUE)
  #clip_mi           <-  getAOI(clip = clip_sf)
  #clip_km           <-  getAOI(clip = list(35, -115, 10, 10), km = TRUE)

  vec = c(

    AOI::checkClass(clip_counties_all, 'Spatial'),

    AOI::checkClass(state.bb, 'Spatial'),

    #AOI::checkClass(clip_4, 'sf'),

    #AOI::checkClass(clip_sf, 'sf'),

    #(clip_mi@bbox[1,1] != clip_km@bbox[1,1]))

  rm(clip_counties_all)
  rm(state.bb)
  #rm(clip_4)
  #rm(clip_sf)
  #rm(clip_mi)
  #rm(clip_km)

  print(all(vec))
  check = all(vec)
  expect_true(check)

})





