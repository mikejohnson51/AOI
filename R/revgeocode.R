# print.geoloc <- function(x) {
#   for(i in 1:NROW(x)){
#     cat(paste0("\n", names(x)[i], paste(rep(" ", 16 - nchar(names(x)[i])), collapse = ""), ":\t"))
#     cat(paste(x[i]))
#   }
# }

#' @title Reverse Geocoding
#' @description Describe a location using the ERSI and OSM reverse geocoding web-services. This service provides tradional reverse geocoding (lat/lon to placename) but can also be use to get more information about a place name.
#' @param point a point provided by \code{numeric} lat/lon pair or \code{character} place name
#' @return a data.frame of descriptive features
#' @export
#' @author Mike Johnson
#' @examples
#' \dontrun{
#'  revgeocode(c(38,-115))
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
#'  revgeocode("UCSB")
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

revgeocode = function(point){

  if(class(point) == 'character') { pt = geocode(point) } else { pt = data.frame(lat =point[1], lon = point[2]) }

# ESRI Rgeocode -----------------------------------------------------------

  esri.url <-paste0("http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/reverseGeocode",
                      "?f=pjson&featureTypes=&location=",
                      paste(pt$lon, pt$lat, sep = ","))

  ll   = jsonlite::fromJSON(esri.url)
  esri = do.call(c, ll)
  esri = do.call(c, esri)

  names(esri) = gsub("address\\.|location\\.|spatialReference\\.", "", names(esri))
  names(esri)[which(names(esri) == 'x')] = 'lon'
  names(esri)[which(names(esri) == 'y')] = 'lat'


# OSM Rgeocode ------------------------------------------------------------

  osm.url = paste0("https://nominatim.openstreetmap.org/reverse?format=json&lat=",
               pt$lat,
               "&lon=",
               pt$lon,
               "&zoom=18&addressdetails=1")

  ll  = jsonlite::fromJSON(osm.url)
  osm = do.call(c, ll)
  osm$licence = NULL

  osm$bb = paste(osm$boundingbox3, osm$boundingbox4, osm$boundingbox1, osm$boundingbox2, sep = ",")
  names(osm) = gsub("address.", "", names(osm))
  osm[grepl('boundingbox', names(osm))] = NULL


# Merge -------------------------------------------------------------------

  tmp = c(osm, esri)


  tmp = tmp[!duplicated(tmp)]

  tmp = tmp[!(names(tmp) %in% c("lat.1", "lon.1", "country_code","Neighborhood", "shorlabel"))]
  names(tmp) = tolower(names(tmp))

  tmp[tmp == ""] = NULL

  tmp = as.data.frame(tmp)

  return(tmp)
}

