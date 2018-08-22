context("geocoding")

test_that("check geocoding routines", {

  google = geocode("UCSB")
  osm = geocode("UCSB", server = 'osm')
  point1 = geocode("UCSB", pt = TRUE, server = 'osm')
  bb1 = geocode("UCSB", bb = TRUE, server = 'osm')
  point3 = geocode(c("UCSB", "Goleta", "Sterns Warf"))
  point2 = geocode(c("UCSB", "Goleta", "Sterns Warf"), pt = TRUE)
  bb2 = geocode(c("UCSB", "Goleta", "Sterns Warf"), bb = TRUE)
  rc1= revgeocode(c(38,-118))
  rc2= revgeocode("Jenny Lake")
  map = check()
  map1 = getAOI("UCSB", sf = T) %>% check()
  map2 = getAOI("UCSB") %>% check(return = T)

  vec = c(length(google) == 2,
          length(osm) == 2,
          class(point1) == 'list',
          class(point3) == 'data.frame',
          names(point1) == c("coords", "pt"),
          class(bb1) == 'list',
          names(bb1) == c("coords", "bb"),
          class(point2) == 'list',
          names(point2) == c("coords", "pts"),
          class(bb2) == 'list',
          names(bb2) == c("coords", "bb"),
          class(rc1)[1] == 'geoloc',
          class(rc2)[1] == 'geoloc',
          is.null(map),
          is.null(map1),
          !is.null(map2)

          )

  check = all(vec)
  expect_true(check)
})


context("other")

test_that("check other routines", {

  clip_sp = getAOI("UCSB")
  clip_sf = getAOI("UCSB", sf =T)
  build_sf = getAOI(clip_sf)
  all_county = getAOI(state = "AL", county = 'all')
  state_bb = getAOI(state = "AL", bb = TRUE)
  geom_str_geom = getAOI("UCSB") %>% bbox_st() %>% bbox_sp()
  sf_str = getAOI("UCSB", sf = TRUE) %>% bbox_st()
  df_geom = c(-118, -117,  37, 38) %>% bbox_sp()
  print(sf_str)
  des = describe(clip_sp)

  vec = c(class(clip_sp) == 'SpatialPolygons',
          class(clip_sf)[1] == "sf",
          class(build_sf)[1] == "SpatialPolygons",
          length(all_county) == 67,
          class(state_bb) == 'SpatialPolygons',
          class(geom_str_geom) == 'SpatialPolygons',
          class(df_geom) == 'SpatialPolygons',
          class(sf_str)[1] == 'bb',
          class(des) == 'data.frame'
  )

  check = all(vec)
  expect_true(check)
})
