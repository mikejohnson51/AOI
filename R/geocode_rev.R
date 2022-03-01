#' @title Reverse Geocoding
#' @description
#' Describe a location using the ERSI and OSM reverse geocoding web-services.
#' This service provides tradional reverse geocoding (lat/lon to placename)
#' but can also be use to get more information about a place name.
#' @param x a point provided by \code{numeric} lat/lon pair or
#'          \code{character} place name
#' @return a data.frame of descriptive features
#' @export
#' @author Mike Johnson
#' @examples
#' \dontrun{
#'  geocode_rev(x = c(38,-115)) %>% t()
#'
#'  ```
#'  county          :	Lincoln County
#'  state           :	Nevada
#'  country         :	USA
#'  place_id        :	198776170
#'  osm_type        :	relation
#'  osm_id          :	166463
#'  lat             :	37.5449476
#'  lon             :	-114.8764448
#'  display_name    :	Lincoln County, Nevada, USA
#'  match_addr      :	89017, Hiko, Nevada
#'  longlabel       :	89017, Hiko, NV, USA
#'  shortlabel      :	89017
#'  addr_type       :	Postal
#'  city            :	Hiko
#'  lon             :	-115
#'  lat             :	38
#'  bb              :	-115.897545,-114.048473,36.8420756,38.678486
#'  ```
#'
#'  geocode_rev("UCSB") %>% t()
#'
#'  ````
#'  library         :	UCSB Library
#'  pedestrian      :	Library Plaza
#'  county          :	Santa Barbara County
#'  state           :	California
#'  postcode        :	93106
#'  country         :	USA
#'  place_id        :	156341322
#'  osm_type        :	way
#'  osm_id          :	355809608
#'  lat             :	34.41399165
#'  lon             :	-119.845522700258
#'  display_name    :	UCSB Library, Library Plaza, Santa Barbara County, California, 93106, USA
#'  match_addr      :	93106, Santa Barbara, California
#'  longlabel       :	93106, Santa Barbara, CA, USA
#'  city            :	Santa Barbara
#'  lat             :	34.4145937
#'  bb              :	-119.8458708,-119.8450475,34.4128884,34.414646
#'  ````
#' }
#' @importFrom jsonlite fromJSON

geocode_rev <- function(x) {

  if (inherits(x, "character")) {
    pt <- geocode(x)
  } else {
    pt <- data.frame(
      lat = x[1],
      lon = x[2]
    )
  }

  # ESRI Rgeocode -----------------------------------------------------------
  # Archived for potentially later support
  #> esri_url <- paste0(
  #>   "http://geocode.arcgis.com/",
  #>   "arcgis/rest/services/World/GeocodeServer/reverseGeocode",
  #>   "?f=pjson&featureTypes=&location=",
  #>   paste(pt$lon, pt$lat, sep = ",")
  #> )
  #> ll   <- jsonlite::fromJSON(esri_url)
  #> xr   <- unlist(ll)
  #> esri <- data.frame(t(xr), stringsAsFactors = F) %>%
  #>         setNames(
  #>           gsub(
  #>             "address\\.|location\\.|spatialReference\\.",
  #>             "",
  #>             names(xr)
  #>           )
  #>         )
  #> names(esri)[which(names(esri) == "x")] <- "lon"
  #> names(esri)[which(names(esri) == "y")] <- "lat"
  #> names(esri)[which(names(esri) == "boundingbox3")] <- "xmin"
  #> names(esri)[which(names(esri) == "boundingbox4")] <- "xmax"
  #> names(esri)[which(names(esri) == "boundingbox1")] <- "ymin"
  #> names(esri)[which(names(esri) == "boundingbox2")] <- "ymax"
  #> esri[grepl("latest", names(esri))] <- NULL


  # OSM Rgeocode ------------------------------------------------------------

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


# Merge -------------------------------------------------------------------

  tmp <- osm #> cbind(osm, esri)
  tmp <- tmp[, tmp != ""]
  #> tmp = tmp %>%
  #>       select(
  #>         -display_name,
  #>         -LongLabel,
  #>         -ShortLabel,
  #>         -country_code
  #>       )

  tmp
}
