#' @title geocodeOSM
#' @description
#' Geocode via Open Street Maps API. \code{geocodeOSM}
#' takes an input string and converts it to a geolocation.
#' Additionally it can return the location as a simple
#' features point and the minimum bounding area
#' of the location extent.
#' @param location a place name
#' @param pt if TRUE a simple feature point is appended to returned list
#' @param bb if TRUE the OSM bounding area of the location is appended
#'           to returned list
#' @param all if TRUE the point and bounding box representations are returned
#' @param method the geocoding service to be used. See ?tidygeocoder::geocode
#' @return at minimum a data.frame of lat, long
#' @export
#' @examples
#' \dontrun{
#' geocodeAOI("UCSB")
#' geocodeAOI("Garden of the Gods", bb = TRUE)
#' }
#' @importFrom tidygeocoder geo
#' @importFrom sf st_as_sf

geocodeAOI <- function(location, pt = FALSE, bb = FALSE,
                      all = FALSE, method = "arcgis") {

  if (sum(pt, bb, all) > 1) {
    stop("Only pt, bb, or all can be TRUE. Leave others as FALSE")
  }

  if (!inherits(location, "character")) {
    stop(paste(
      "",
      "Input location is not a place name. ",
      "You might be looking for reverse geocodeing.",
      "Try: AOI::geocode_rev()",
      sep = "\n"
    ))
  }

  ret = suppressMessages({
    tidygeocoder::geo(location, progress_bar = FALSE, method = method, full_results = TRUE)
  })



  ret$lon = ret$long
  ret$long = NULL
  ret$request = location
  ret$address = NULL

  if(all(is.na(ret$lat))){
    return(ret)
  }

  bbs = list()

  for(i in 1:nrow(ret)){
    bbs[[i]] <- st_bbox(c(xmin = ret$extent.xmin[i],
                     xmax = ret$extent.xmax[i],
                     ymin = ret$extent.ymin[i],
                     ymax = ret$extent.ymax[i]), crs = 4326) %>%
      sf::st_as_sfc() %>%
      sf::st_as_sf() %>%
      rename_geometry("geometry")
  }

  bbs =  do.call(rbind, bbs)
  bbs$request = ret$request

  ret = ret[, !grepl("[.]", names(ret))]

  bbs = merge(bbs, ret)

  point <- sf::st_as_sf(x = ret, coords = c("lon", "lat"), crs = 4269)


  if (pt)  {  return(point) }
  if (bb)  {  return(bbs)  }
  if (all) {  return(list(coords = ret, pt = point, bbox = bbs)) }

  return(ret)
}


#' @title Geocoding
#' @description
#' A wrapper around the OpenSteetMap geocoding web-services.
#' Users can request a lat/lon pair, spatial points, and/or
#' a bounding box geometries. One or more place name can be
#' given at a time. If a single point is requested, `geocode`
#' will provide a data.frame of lat/lon values and, if requested,
#' a spatial point object and the geocode derived bounding box.
#' If multiple place names are given, the returned objects will
#' be a data.frame with columns for input name-lat-lon; if requested,
#' a SpatialPoints object will be returned; and a minimum bounding box
#' of all place names.
#' @param location \code{character}. Place name(s)
#' @param zipcode \code{character}. USA zipcode(s)
#' @param event \code{character}. a term to search for on wikipedia
#' @param pt \code{logical}. If TRUE point geometery is appended
#'           to the returned list()
#' @param bb \code{logical}. If TRUE bounding box geometry is
#'           appended to the returned list()
#' @param full \code{logical}. If TRUE all attributes reuturned
#'             with query, else just the lat/long pair.
#' @param all if TRUE the point and bounding box representations are returned
#' @return at minimum a data.frame of lat/lon coordinates.
#'         Possible list with appended spatial features of
#'         type \code{sf} or \code{sp}
#' @export
#' @author Mike Johnson
#' @examples
#' \dontrun{
#' ## geocode a single location
#' geocode("UCSB")
#'
#' ## geocode a single location and return a SpatialPoints object
#' geocode("UCSB", pt = TRUE)
#'
#' ## geocode a single location and derived bounding box of location
#' geocode(location = "UCSB", bb = TRUE)
#'
#' ## geocode multiple locations
#' geocode(c("UCSB", "Goleta", "Santa Barbara"))
#'
#' ## geocode multiple points and generate a minimum bounding box of all locations and spatial points
#' geocode(c("UCSB", "Goleta", "Santa Barbara"), bb = T, pt = T)
#' }
#'
geocode <- function(location = NULL,
                    zipcode = NULL,
                    event = NULL,
                    pt = FALSE,
                    bb = FALSE,
                    all = FALSE,
                    full = FALSE) {

  if (!is.null(event)) {
    suppressWarnings({
      locs <-  do.call(rbind,lapply(event, geocode_wiki))
    })

    if(pt | bb | all){
      locs = sf::st_as_sf(locs, coords = c("lon", "lat"), crs = 4269)
    }
  }

  if (!is.null(zipcode)) {

    locs <- AOI::zipcodes[match(as.numeric(zipcode), AOI::zipcodes$zipcode), ]

    failed <- zipcode[!zipcode %in% locs$zip]

    if (length(failed) > 0 & all(is.na(locs$lat))) {
      stop("Zipcodes ", paste(failed, collapse = ", "), " not found.")
    } else if (length(failed) > 0 ){
      warning("Zipcodes ", paste(failed, collapse = ", "), " not found.")
      locs = locs[!is.na(locs$zipcode),]
    }

    if(pt | bb | all){
      locs = sf::st_as_sf(locs, coords = c("lon", "lat"), crs = 4269)
    }
  }

  if (!is.null(location)) {
    locs = geocodeAOI(location, pt, bb, all)
  }

  return(locs)
}


#' @title Alternate Page Finder
#' @description Find linked pages to a wikipedia call
#' @param loc a wikipedia structured call
#' @param pts \code{logical}. If TRUE point geometery
#'            is appended to the returned list()
#' @return at minimum a data.frame of lat, long
#' @author Mike Johnson
#' @keywords internal
#' @export
#' @examples
#' \dontrun{
#' alt_page("Twin_towers")
#' }
#' @importFrom rvest read_html html_nodes html_attr html_text

alt_page <- function(loc, pt = FALSE) {

  tt <- rvest::read_html(paste0(
    "https://en.wikipedia.org/w/index.php?search=",
    loc,
    "&title=Special%3ASearch&go=Go"
  ))

  a <- rvest::html_nodes(tt, "a")

  url_ <- rvest::html_attr(a, "href")

  link_ <- rvest::html_text(a)

  df_new <- data.frame(urls = url_, links = link_)
  df_new <- df_new[!is.na(df_new$urls), ]
  df_new <- df_new[!is.na(df_new$links), ]
  df_new <- df_new[grepl("/wiki/", df_new$urls), ]
  df_new <- df_new[!grepl(":", df_new$urls), ]
  df_new <- df_new[!grepl("Main_Page", df_new$urls), ]
  df_new <- df_new[!grepl("Privacy_Policy", df_new$urls), ]
  df_new <- df_new[!grepl("Terms_of_use", df_new$urls), ]

  if(nrow(df_new) == 0) { df_new <- NULL }

  return(df_new)
}


#' @title Geocoding Events
#' @description A wrapper around the Wikipedia API to return
#'              geo-coordinates of requested inputs.
#' @param event \code{character}. a term to search for on wikipeida
#' @param pt \code{logical}. If TRUE point geometery is appended
#'           to the returned list()
#' @return aa data.frame of lat/lon coordinates
#' @export
#' @examples
#' \dontrun{
#' ## geocode an Agency
#' geocode_wiki("NOAA")
#'
#' ## geocode an event
#' geocode_wiki("I have a dream speech")
#'
#' ## geocode a n event
#' geocode_wiki("D day")
#'
#' ## geocode a product
#' geocode_wiki("New York Times")
#'
#' ## geocode an event
#' geocode_wiki("Hurricane Harvey")
#' }
#' @importFrom jsonlite fromJSON
#' @importFrom rvest read_html html_nodes html_table
#' @importFrom rnaturalearth ne_countries
#' @importFrom sf st_as_sf

geocode_wiki <- function(event = NULL, pt = FALSE) {

  loc <- gsub(" ", "+", event)

  u <- paste0(
    "https://en.wikipedia.org/w/api.php?action=opensearch&search=",
    loc,
    "&limit=1&format=json&redirects=resolve"
  )

  url <- unlist(jsonlite::fromJSON(u))
  url <- url[grepl("http", url)]
  call <- gsub("https://en.wikipedia.org/wiki/", "", url)

  if (length(call) == 0) {
    df_new <- alt_page(loc)
    message(
      "'",
      event,
      "' not found...\nTry one of the following?\n\n",
      paste(df_new$links, collapse = ",\n")
    )

    return(df_new)

  } else {

    coord_url <- paste0('https://en.wikipedia.org/w/api.php?action=query&prop=coordinates&titles=',
                        paste(call, collapse = "|"),
                        '&format=json')


    fin <- jsonlite::fromJSON(coord_url)

    extract = function(x){
      if(!is.null(x$coordinates)){
        data.frame(title = x$title, lat = x$coordinates$lat, lon = x$coordinates$lon)
      } else {
        NULL
      }
    }

    df = do.call(rbind, lapply(fin$query$pages, extract))

    if (is.null(df)) {
      infobox <-
        rvest::read_html(url, header = FALSE) %>%
        rvest::html_nodes(xpath = '//table[contains(@class, "infobox")]')

      if (length(infobox) == 0) {
        df_new <- alt_page(loc)
        message(
          "'",
          event,
          "' not found...\nTry one of the following?\n\n",
          paste(df$links, collapse = ",\n")
        )
        return(df_new)
      } else {
        y <- as.data.frame(
          rvest::html_table(infobox[1], header = F)[[1]],
          stringsAsFactors = FALSE
        )
        search <- y$X2[which(y$X1 == "Location")]
      }

      if (length(search) == 0) {
        search <- y$X2[which(y$X1 == "Headquarters")]
      }

      if (length(search) == 0) {
        meta <- list_states()
        countries <- rnaturalearth::ne_countries(returnclass = "sf")
        y <- y[y$X1 != y$X2, ]
        x <- y[grepl(tolower(paste0(c(meta$name, countries$name), collapse = "|")), tolower(y$X2)), ]

        all <- strsplit(gsub(", ", ",", x[1, 2]), ",")[[1]]
        df <- list()
        for (i in seq_len(length(all))) {
          df[[i]] <- geocode(all[i], full = FALSE)
        }

        df <- cbind(all, do.call(rbind, df))

      } else {
        s1 <- noquote(unlist(strsplit(search, ", ")))
        df <- NULL
        i <- 0

        while (NROW(df) == 0) {
          i <- i + 1
          def <- gsub('/"', "", do.call(paste, list(s1[c(1:i)])))
          df <- geocode(def, full = TRUE)
        }
      }
    }
  }

  if (pt) {
    sf::st_as_sf(x = df, coords = c("lon", "lat"), crs = 4269)
  } else {
    data.frame(cbind(request = loc, df))
  }

}

#' @title Reverse Geocoding
#' @description
#' Describe a location using the ERSI and OSM reverse geocoding web-services.
#' This service provides tradional reverse geocoding (lat/lon to placename)
#' but can also be use to get more information about a place name.
#' @param x a point provided by \code{numeric} lat/lon pair or
#'          \code{character} place name
#' @param method "osm" (deafalt) or "ersi"
#' @return a data.frame of descriptive features
#' @export
#' @author Mike Johnson
#' @examples
#' \dontrun{
#'  geocode_rev(x = c(38,-115))
#'  geocode_rev("UCSB")
#' }
#' @importFrom jsonlite fromJSON

geocode_rev <- function(x, method = "osm") {

  if (inherits(x, "character")) {
    pt <- geocode(x)
  } else if(inherits(x, "numeric")){
    pt <- data.frame(
      lat = x[1],
      lon = x[2]
    )
  } else {
    coords = sf::st_coordinates(sf::st_centroid(x))
    pt <- data.frame(
      lat = coords[2],
      lon = coords[1]
    )
  }

  # ESRI Rgeocode -----------------------------------------------------------

  if(method == "esri"){
   esri_url <- paste0(
     "https://geocode.arcgis.com/",
     "arcgis/rest/services/World/GeocodeServer/reverseGeocode",
     "?f=pjson&featureTypes=&location=",
     paste(pt$lon, pt$lat, sep = ",")
   )

    ll   <- jsonlite::fromJSON(esri_url)
    xr   <- unlist(ll)
    esri <- data.frame(t(xr), stringsAsFactors = F)
    names(esri) <- gsub(
               "address\\.|location\\.|spatialReference\\.",
               "",
               names(xr)
             )

   names(esri)[which(names(esri) == "x")] <- "lon"
   names(esri)[which(names(esri) == "y")] <- "lat"
   names(esri)[which(names(esri) == "boundingbox3")] <- "xmin"
   names(esri)[which(names(esri) == "boundingbox4")] <- "xmax"
   names(esri)[which(names(esri) == "boundingbox1")] <- "ymin"
   names(esri)[which(names(esri) == "boundingbox2")] <- "ymax"
   esri[grepl("latest", names(esri))] <- NULL
   tmp = esri
  }

  # OSM Rgeocode ------------------------------------------------------------
 if(method == "osm"){
  osm_url <- paste0(
    "https://nominatim.openstreetmap.org/reverse?format=json&lat=",
    pt$lat,
    "&lon=",
    pt$lon,
    "&zoom=18&addressdetails=1"
  )

  ll  <- jsonlite::fromJSON(osm_url)
  xr  <- unlist(ll)
  osm <- data.frame(t(xr), stringsAsFactors = FALSE)
  names(osm) <- gsub("address\\.|location\\.|spatialReference\\.", "", names(xr))

  osm$licence <- NULL

  osm$bb <- paste(
    osm$boundingbox3,
    osm$boundingbox4,
    osm$boundingbox1,
    osm$boundingbox2,
    sep = ","
  )

  osm[grepl("boundingbox", names(osm))] <- NULL
  osm[grepl("lat", names(osm))]         <- NULL
  osm[grepl("lon", names(osm))]         <- NULL
  tmp = osm
 }

  tmp
}
