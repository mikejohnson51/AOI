context("geocode.R and geocodeOSM.R")

test_that("check geocoding routines", {

  df = geocode("UCSB", full = FALSE)
  df.full = geocode("UCSB", full = T)
  point = geocode("UCSB", pt = TRUE)
  bb = geocode("UCSB", bb = TRUE)
  point3 = geocode(c("UCSB", "Goleta", "Stearns Wharf"))
  point3.full = geocode(c("UCSB", "Goleta", "Stearns Wharf"), full = T)
  bb2 = geocode(c("UCSB", "Goleta", "Stearns Wharf"), all  = TRUE)

  # Does geocode return a lat / long values that are numeric?
  expect_true(length(df) == 3)
  expect_true(is.numeric(df$lat))
  expect_true(is.numeric(df$lon))

  # Does turning on 'full' add details?
  expect_true(length(df.full) > 2)

  # Does tuning on point create a POINT geometry (sf)
  expect_true(sf::st_geometry_type(point) == 'POINT')

  # Does tuning on bb create a POLYGON geometry (sf)
  expect_true(sf::st_geometry_type(bb) == 'POLYGON')

  #Does adding 3 input create three rows of data?
  expect_true(NROW(point3) == 3)

  #Does multiple queries and full=T generate additional data?
  expect_true(NCOL(point3.full) > NCOL(point3))

  # Do multiple queries and pt=T generate points?
  expect_true(all(sf::st_geometry_type(bb2$pt) == 'POINT') )

  # Do multiple queries and bb=T produce a bounding box?
  expect_true(sf::st_geometry_type(bb2$bb) == 'POLYGON')

})

test_that("geocodeOSM throws correct errors", {
  # Make sure geocode does not process numeric inputs
  expect_error(geocode(37), "\nInput location is not a place name. \nYou might be looking for reverse geocodeing.\nTry: AOI::geocode_rev")

  # Make sure unfindable locations return NA values but dont break the routine
  bad = geocode("TweedleDee_TweedleDumb")
  expect_true(is.na(bad$lat))
  expect_true(is.na(bad$lon))
})

test_that("bbox_get works as expected...", {

 yy = bbox_get(c(37,38,-120,-119))
 expect_true(sf::st_geometry_type(yy) == 'POLYGON')

 yy2 = aoi_get(state = 'CA') %>% bbox_get()
 expect_true(sf::st_geometry_type(yy2) == 'POLYGON')

 r = raster::raster(system.file("external/test.grd", package="raster"))
 yy3 = bbox_get(r)
 expect_true(sf::st_geometry_type(yy3) == 'POLYGON')

})


test_that("bbox_get and bbox_coords work as expected...", {

  A  = aoi_get("UCSB")
  bbsf = bbox_get(A)
  bbsf_vec = bbox_coords(A)
  expect_true(sf::st_geometry_type(bbsf) == 'POLYGON')
  expect_true(length(bbsf_vec) == 4)

  A  = A %>% sf::as_Spatial()
  bbsp = bbox_get(A)
  bbsp_vec = bbox_coords(A)
  expect_true(sf::st_geometry_type(bbsp) == 'POLYGON')
  expect_true(length(bbsp_vec) == 4)

  # r = raster::raster(system.file("external/test.grd", package="raster"))
  bbr = bbox_get(r)
  bbr_vec = bbox_coords(r)
  expect_true(sf::st_geometry_type(bbr) == 'POLYGON')
  expect_true(length(bbr_vec) == 4)

})


test_that("is_inside...", {
#r = raster::raster(system.file("external/test.grd", package="raster"))
lake_tahoe = aoi_get(list("Lake Tahoe", 100, 100))
CA = aoi_get(state="CA")
SB = aoi_get(state = "CA", county = "Santa Barbara")

# Is Lake tahoe completly inside CA?
expect_false(aoi_inside(CA, lake_tahoe, total = T))
expect_true(aoi_inside(CA, lake_tahoe, total = F))
expect_true(aoi_inside(CA, SB, total = F))

expect_true(aoi_inside(CA, SB, total = F))
expect_true(aoi_inside(sf::as_Spatial(CA), sf::as_Spatial(SB), total = F))

expect_false(aoi_inside(r, SB))
expect_false(aoi_inside(SB, r))

})

test_that("aoi_buffer", {
  CA = aoi_get(state="CA")
  pure_area = sf::st_area(CA)
  grow = sf::st_area(aoi_buffer(CA, 10))
  shrink = sf::st_area(aoi_buffer(CA, -10))

  expect_true(pure_area > shrink)
  expect_true(pure_area < grow)

  ucsb = aoi_get("UCSB")
  growUCSB_mile = aoi_buffer(ucsb, 10)
  growUCSB_km   = aoi_buffer(ucsb, 10, km = TRUE)

  do = aoi_describe(ucsb)
  dm = aoi_describe(growUCSB_mile)

  expect_true(round(do$height, 0) == (round(dm$height,0) -20))
  expect_true(sf::st_area(growUCSB_mile) > sf::st_area(growUCSB_km))
})

test_that("getAOI errors...", {
  expect_error(aoi_get(state = "CA", x = "UCSB"),
               "Only 'state' or 'clip' can be used. Set the other to NULL")

  expect_error(aoi_get(state = 10),
               "State must be a character value.")

  expect_error(aoi_get(state = "TweedleDee"),
               "State not recongized. Full names or abbreviations can be used.")

  expect_error(aoi_get(county = "Santa Barbara"),
               "The use of 'county' requires a 'state' parameter as well.")

  expect_error(aoi_get(state = NULL, clip = NULL),
               "Requires a 'clip' or 'state' parameter to execute.")

  })

test_that("getAOI & getFiat & getClip & defineClip", {
  CA = aoi_get(state = "CA")
  expect_true(CA$state_abbr == "CA")

  SB = aoi_get(state = "CA", county = "Santa Barbara")
  expect_true(SB$name == "Santa Barbara")

  ALL = aoi_get(state = "CA", county = "all")
  expect_true(NROW(ALL) == 58)

  brazil = aoi_get(country = "Brazil")
  expect_true(brazil$name == "Brazil")

  brazil2 = aoi_get(country = "BR")
  expect_true(brazil2$name == "Brazil")

  brazil3 = aoi_get(country = "BRA")
  expect_true(brazil3$name == "Brazil")

  expect_error(aoi_get(country = "BRAAAAAAA"),
               "no country found")

  expect_error(aoi_get(state = "CA", county = "Dallas"),
                "Dallas not a valid county in California.")

  conus = aoi_get(state = "conus")
  expect_true(NROW(conus) == 49)

  conus_all = aoi_get(state = "all")
  expect_true(NROW(conus_all) == 52)

  conus_u = aoi_get(state = "conus", union = TRUE)
  expect_true(NROW(conus_u) == 1)

  # r = raster::raster(system.file("external/test.grd",
  #                                package="raster"))
  AOIr = aoi_get(r) %>% st_transform(r@crs) %>%  bbox_coords()
  expect_true(raster::extent(r)[1] == round(AOIr$xmin,0))
  expect_true(raster::extent(r)[2] == round(AOIr$xmax,0))
  expect_true(raster::extent(r)[3] == round(AOIr$ymin,0))
  expect_true(raster::extent(r)[4] == round(AOIr$ymax,0))

  fname <- system.file("shape/nc.shp", package="sf")
  nc <- sf::read_sf(fname)

  sf_obj = aoi_get(nc)
  sp_obj = aoi_get(sf::as_Spatial(nc))

  expect_true(identical(sf_obj, sp_obj))

  d1 = aoi_get("UCSB")
  expect_true(d1$request == "UCSB")

  d2 = aoi_get(list("UCSB", 10, 10))
  d3 = aoi_get(list("UCSB", 10, 10, center = "center"))
  expect_true(identical(d2,d3))

   dul = aoi_get(list("UCSB", 10, 10, center = "upperleft"))
   dll = aoi_get(list("UCSB", 10, 10, center = "lowerleft"))
   dur = aoi_get(list("UCSB", 10, 10, center = "upperright"))
   dlr = aoi_get(list("UCSB", 10, 10, center = "lowerright"))

   expect_false(identical(dul, dll))
   expect_false(identical(dul, dur))
   expect_false(identical(dul, dlr))

   num = aoi_get(list(37,-119, 10, 10))
   num2 = aoi_get(list(37,-119, 10, 10, "center"))
   expect_true(sf::st_geometry_type(num) == 'POLYGON')
   expect_true(identical(num, num2))

   expect_error(aoi_get(list(899,-119, 10, 10)),
                'Latitude must be vector element 1 and between -90 and 90')
   expect_error(aoi_get(list(-899,-119, 10, 10)),
                'Latitude must be vector element 1 and between -90 and 90')

   expect_error(aoi_get(list(39, 190, 10, 10)),
                'Longitude must be vector element 2 and between -180 and 180')

   expect_error(aoi_get(list(39, -190, 10, 10)),
                'Longitude must be vector element 2 and between -180 and 180')

   cali_mex = aoi_get(state = "CA", country = "MX")
   cali_county_mex = aoi_get(state = "CA", county = 'all', country = "MX")

   expect_true(all(cali_mex$NAME %in% c("California", "Mexico")) )
   expect_true(nrow(cali_county_mex) == 59)

   expect_error(geocode("UCSB", pt = T, bb = T), 'Only pt, bb, or all can be TRUE. Leave others as FALSE')


})

test_that("aoi_describe", {

  xx   =  aoi_describe(aoi_get(state= "CA"))
  xxf  = aoi_describe(aoi_get(state = "CA"), full = T)
  xxkm = aoi_describe(aoi_get(state ="CA"), km = T)

  yy = aoi_describe(aoi_get("Fresno"), full =T)
  y1 = aoi_describe(r, full = T)

  expect_true(NCOL(xx) < NCOL(xxf))
  expect_true(xxkm$height < xx$height)

  rev = geocode_rev("UCSB")

  expect_error(aoi_get(list(10,10,10, "upperleft")), NULL)
  expect_error(aoi_get(list(10,10,10)), NULL)
  expect_error(aoi_get(10), NULL)

  CA    = aoi_get(state = "CA") %>% bbox_get()
  CAsf = aoi_get(x = aoi_get(state = "CA"))
  CAsp=  aoi_get(x = as_Spatial(aoi_get(state = "CA")))

  expect_true(identical(CA, CAsf))
  expect_true(identical(CA, CAsp))

})

test_that("check...", {
  AOI = geocode("Denver", all = T)
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

  den = geocode_wiki("Denver", pt = TRUE)
  brexit = suppressMessages(geocode_wiki("Brexit"))
  harvey = geocode_wiki("Hurricane Harvey")
  force_null = geocode_wiki(event = "XYZmikeZYX")

  expect_null(force_null)

  noaa = geocode_wiki("NOAA", pt = TRUE)

  expect_true(nrow(harvey) > 1)

  #checkClass(NROW)
  expect_true(sf::st_geometry_type(den) == 'POINT')
  expect_true(sf::st_geometry_type(noaa) == 'POINT')
  den_f = geocode_wiki("Denver", pt = F)
  expect_true(length(den_f) == 3)

})


test_that("zipcodes...", {

  many = geocode(zipcode = c(93106, 80906))
  single = geocode(zipcode = c(93106))
  points = geocode(zipcode = 93106, pt = T)
  bb = geocode(zipcode =  c(93106, 80906), bb = T)

  r = geocode(zipcode = c('32003', '32004', '32006', '32007',
                          '32008', '32009', '33011', '32013',
                          '32024', '32025'), pt = T)

  expect_true(NROW(many) == 2)
  expect_true(NROW(single) == 1)
  expect_true(sf::st_geometry_type(points) == 'POINT')
  expect_true(sf::st_geometry_type(bb) == 'POLYGON')
  expect_true(NROW(r) == 10)

})




