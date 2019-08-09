context("geocode.R and geocodeOSM.R")

test_that("check geocoding routines", {

  df = geocode("UCSB", full = FALSE)
  df.full = geocode("UCSB", full = T)
  point = geocode("UCSB", pt = TRUE)
  bb = geocode("UCSB", bb = TRUE)
  point3 = geocode(c("UCSB", "Goleta", "Stearns Wharf"))
  point3.full = geocode(c("UCSB", "Goleta", "Stearns Wharf"), full = T)
  bb2 = geocode(c("UCSB", "Goleta", "Stearns Wharf"), pt = T, bb = TRUE)

  expect_true(length(df) == 2)
  expect_true(is.numeric(df$lat))
  expect_true(is.numeric(df$lon))
  expect_true(length(df.full) > 2)
  expect_true(sf::st_geometry_type(point$pt) == 'POINT')
  expect_true(sf::st_geometry_type(bb$bb) == 'POLYGON')
  expect_true(NROW(point3) == 3)
  expect_true(NCOL(point3.full) > NCOL(point3))
  expect_true(all(sf::st_geometry_type(bb2$pt) == 'POINT') )
  expect_true(sf::st_geometry_type(bb2$bb) == 'POLYGON')

})

test_that("geocodeOSM throws correct errors", {
  expect_error(geocode(37), "\nInput location is not a place name. \nYou might be looking for reverse geocodeing.\nTry: AOI::revgeocode")
  bad = geocode("TweedleDee_TweedleDumb")

  expect_true(is.na(bad$lat))
  expect_true(is.na(bad$lon))
})

test_that("bbox_sp works as expected...", {
 yy = bbox_sp(c(37,38,-120,-119))
 expect_true(sf::st_geometry_type(yy) == 'POLYGON')

 r = raster::raster(system.file("external/test.grd", package="raster"))
 yy2 = bbox_sp(r)
 expect_true(sf::st_geometry_type(yy2) == 'POLYGON')

})


test_that("getBoundingBox and bbox_st work as expected...", {

  A  = getAOI("UCSB")
  bbsf = getBoundingBox(A)
  bbsf_vec = bbox_st(A)
  expect_true(sf::st_geometry_type(bbsf) == 'POLYGON')
  expect_true(length(bbsf_vec) == 4)

  A  = getAOI("UCSB") %>% sf::as_Spatial()
  bbsp = getBoundingBox(A)
  bbsp_vec = bbox_st(A)
  expect_true(sf::st_geometry_type(bbsp) == 'POLYGON')
  expect_true(length(bbsp_vec) == 4)

  r = raster::raster(system.file("external/test.grd", package="raster"))
  bbr = getBoundingBox(r)
  bbr_vec = bbox_st(A)
  expect_true(sf::st_geometry_type(bbr) == 'POLYGON')
  expect_true(length(bbr_vec) == 4)

})


test_that("is_inside...", {
r = raster::raster(system.file("external/test.grd", package="raster"))
lake_tahoe = getAOI(list("Lake Tahoe", 100, 100))
CA = getAOI(state="CA")
SB = getAOI(state = "CA", county = "Santa Barbara")

# Is Lake tahoe completly inside CA?
expect_false(is_inside(CA, lake_tahoe, total = T))
expect_true(is_inside(CA, lake_tahoe, total = F))
expect_true(is_inside(CA, SB, total = F))

expect_true(is_inside(CA, SB, total = F))
expect_true(is_inside(sf::as_Spatial(CA), sf::as_Spatial(SB), total = F))

expect_false(is_inside(r, SB))
expect_false(is_inside(SB, r))

})

# test_that("modify...", {
#   CA = getAOI(state="CA")
#   pure_area = sf::st_area(CA)
#   grow = sf::st_area(modify(CA, 10))
#   shrink = sf::st_area(modify(CA, -10))
#
#   expect_true(pure_area > shrink)
#   expect_true(pure_area < grow)
#
#   ucsb = getAOI("UCSB")
#   growUCSB_mile = modify(ucsb, 10)
#   growUCSB_km   = modify(ucsb, 10, km = TRUE)
#
#   do = describe(ucsb)
#   dm = describe(growUCSB_mile)
#
#   expect_true(round(do$height, 0) == (round(dm$height,0) -20))
#   expect_true(sf::st_area(growUCSB_mile) > sf::st_area(growUCSB_km))
# })

test_that("getAOI errors...", {
  expect_error(getAOI(state = "CA", clip = "UCSB"),
               "Only 'state' or 'clip' can be used. Set the other to NULL")

  expect_error(getAOI(state = 10),
               "State must be a character value. Try surrounding in qoutes...")

  expect_error(getAOI(state = "TweedleDee"),
               "State not recongized. Full names or abbreviations can be used. Please check spelling.")

  expect_error(getAOI(county = "Santa Barbara"),
               "The use of 'county' requires the 'state' parameter be used as well.")

  expect_error(getAOI(state = NULL, clip = NULL),
               "Requires a 'clip' or 'state' parameter to execute.")

  })

test_that("getAOI & getFiat & getClip & defineClip", {
  CA = getAOI(state = "CA")
  expect_true(CA$state_abbr == "CA")

  SB = getAOI(state = "CA", county = "Santa Barbara")
  expect_true(SB$name == "Santa Barbara")

  ALL = getAOI(state = "CA", county = "all")
  expect_true(NROW(ALL) == 58)

  brazil = getAOI(country = "Brazil")
  expect_true(brazil$NAME == "Brazil")

  brazil2 = getAOI(country = "BR")
  expect_true(brazil2$NAME == "Brazil")

  brazil3 = getAOI(country = "BRA")
  expect_true(brazil3$NAME == "Brazil")

  expect_error(getAOI(country = "BRAAAAAAA"),
               "no country found")

  expect_error(getAOI(state = "CA", county = "Dallas"),
                "Dallas not a valid county in California.")

  CAbb = getAOI(state = "CA", bb = T)
  CAbb2 = getAOI(state = "CA") %>% getBoundingBox()

  expect_true(identical(CAbb, CAbb2))

  conus = getAOI(state = "conus")
  expect_true(NROW(conus) == 49)

  conus_all = getAOI(state = "all")
  expect_true(NROW(conus_all) == 52)

  conus_u = getAOI(state = "conus", union = TRUE)
  expect_true(NROW(conus_u) == 1)

  r = raster::raster(system.file("external/test.grd", package="raster"))
  AOIr = getAOI(r) %>% st_transform(r@crs) %>%  bbox_st()
  expect_true(raster::extent(r)[1] == round(AOIr$xmin,0))
  expect_true(raster::extent(r)[2] == round(AOIr$xmax,0))
  expect_true(raster::extent(r)[3] == round(AOIr$ymin,0))
  expect_true(raster::extent(r)[4] == round(AOIr$ymax,0))

  fname <- system.file("shape/nc.shp", package="sf")
  nc <- sf::st_read(fname)

  sf_obj = getAOI(nc)
  sp_obj = getAOI(sf::as_Spatial(nc))

  expect_true(identical(sf_obj, sp_obj))

  d1 = getAOI("UCSB")
  expect_true(d1$place_id == 187839739)

  d2 = getAOI(list("UCSB", 10, 10))
  d3 = getAOI(list("UCSB", 10, 10, center = "center"))
  expect_true(identical(d2,d3))

   dul = getAOI(list("UCSB", 10, 10, center = "upperleft"))
   dll = getAOI(list("UCSB", 10, 10, center = "lowerleft"))
   dur = getAOI(list("UCSB", 10, 10, center = "upperright"))
   dlr = getAOI(list("UCSB", 10, 10, center = "lowerright"))

   expect_false(identical(dul, dll))
   expect_false(identical(dul, dur))
   expect_false(identical(dul, dlr))

   num = getAOI(list(37,-119, 10, 10))
   num2 = getAOI(list(37,-119, 10, 10, "center"))
   expect_true(sf::st_geometry_type(num) == 'POLYGON')
   expect_true(identical(num, num2))

   expect_error(getAOI(list(899,-119, 10, 10)),
                'Latitude must be vector element 1 and between -90 and 90')
   expect_error(getAOI(list(-899,-119, 10, 10)),
                'Latitude must be vector element 1 and between -90 and 90')

   expect_error(getAOI(list(39, 190, 10, 10)),
                'Longitude must be vector element 2 and between -180 and 180')

   expect_error(getAOI(list(39, -190, 10, 10)),
                'Longitude must be vector element 2 and between -180 and 180')
})

test_that("describe", {

  r = raster::raster(system.file("external/test.grd", package="raster"))
  xx =describe(getAOI(state= "CA"))
  xxf = describe(getAOI(state = "CA"), full = T)
  xxkm = describe(getAOI(state ="CA"), km = T)

  yy = describe(getAOI("Fresno"), full =T)
  describe(getAOI("Denver"), full = T)
  y1 = describe(r, full = T)

  expect_true(NCOL(xx) < NCOL(xxf))
  expect_true(xxkm$height < xx$height)

  r = revgeocode("UCSB")

  expect_error(getAOI(list(10,10,10, "upperleft")), NULL)
  expect_error(getAOI(list(10,10,10)), NULL)
  expect_error(getAOI(10), NULL)

  CA=getAOI(state = "CA", bb = T)
  CAsf=getAOI(clip = getAOI(state = "CA"))
  CAsp=getAOI(clip = as_Spatial(getAOI(state = "CA")))

  expect_true(identical(CA, CAsf))
  expect_true(identical(CA, CAsp))

})

test_that("check...", {
  AOI = geocode("Denver", pt = T, bb = T)
  A = check(AOI)
  M = check(AOI, returnMap = T)
  Mnull = check()
  br = getAOI(country = "BR")
  Map_br = check(br)

  r = raster::raster(system.file("external/test.grd", package="raster"))
  Mr = check(r)

  expect_null(Mnull)
  expect_true(length(AOI) == 3)
  expect_true(identical(AOI, A))
  expect_true(checkClass(M, "leaflet"))
  expect_true(identical(r, Mr))
  expect_true(identical(br$NAME, Map_br$NAME))
})


test_that("check...", {

  den = geocode_wiki("Denver")
  brexit = suppressMessages(geocode_wiki("Brexit"))
  harvey = geocode_wiki("Hurricane Harvey")
  force_null = geocode_wiki(event = "XYZmikeZYX")
  expect_null(force_null)
  noaa = geocode_wiki("NOAA")

  expect_true(NROW(harvey) > 1)


  #checkClass(NROW)
  expect_true(sf::st_geometry_type(den) == 'POINT')
  expect_true(sf::st_geometry_type(noaa) == 'POINT')
  den_f = geocode_wiki("Denver", pt = F)
  expect_true(length(den_f) == 2)

})



