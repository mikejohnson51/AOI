print.geoloc <- function(x) {
  for(i in 1:NCOL(x)){
    cat(paste0("\n", names(x)[i], paste(rep(" ", 16 - nchar(names(x)[i])), collapse = ""), ":\t"))
    cat(paste(x[i]))
  }
}

#' @title Reverse Geocoding
#' @description Describe a location using the ERSI and OSM reverse geocoding web-services. This service provides tradional reverse geocoding (lat/long to placename) but can also be use to get more information about a place name.
#' @param point a point provided by \code{numeric} lat,long pair or \code{character} place name
#' @return a data.frame of descriptive features
#' @export
#' @author Mike Johnson
#' @examples
#' \dontrun{
#'  revgeocode(c(38,-115))
#'
#'  ```
#'  county          :	Lincoln Count
#'  state           :	Nevada
#'  country         :	United States of America
#'  place_id        :	198776170
#'  osm_type        :	relation
#'  osm_id          :	166463
#'  lat             :	37.5449476
#'  lon             :	-114.8764448
#'  bb              :	-115.897545,-114.048473,36.8420756,38.678486
#'  match_addr      :	89017, Hiko, Nevada
#'  longlabel       :	89017, Hiko, NV, USA
#'  shortlabel      :	89017
#'  addr_type       :	Postal
#'  city            :	Hiko
#'  countrycode     :	USA
#'  ```
#'
#'  revgeocode("UCSB")
#'
#'  ````
#'  university      :	UCSB
#'  pedestrian      :	Library Plaza
#'  county          :	Santa Barbara County
#'  state           :	California
#'  postcode        :	93106
#'  country         :	United States of America
#'  place_id        :	187839690
#'  osm_type        :	way
#'  osm_id          :	542863702
#'  lat             :	34.4145937
#'  lon             :	-119.84581949869
#'  bb              :	-119.8851155,-119.8360437,34.4047282,34.4243918
#'  match_addr      :	93106, Santa Barbara, California
#'  longlabel       :	93106, Santa Barbara, CA, USA
#'  addr_type       :	Postal
#'  city            :	Santa Barbara
#'  countrycode     :	USA
#'  ````
#' }

revgeocode = function(point){

  if(class(point) == 'character') { pt = geocode(point) } else { pt = data.frame(lat =point[1], lon = point[2]) }

# ESRI Rgeocode -----------------------------------------------------------

  esri.url <-paste0("http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/reverseGeocode",
                      "?f=pjson&featureTypes=&location=",
                      paste(pt$lon, pt$lat, sep = ",")
  )

  ll = readLines(esri.url, warn = F)

  x = rbind(
    Match_addr = gsub(" ", " ", gsub(".*: \"s*|\".*", "", ll[grepl("\"Match_addr\":", ll)])),
    LongLabel = gsub(" ", " ", gsub(".*: \"s*|\".*", "", ll[grepl("\"LongLabel\":", ll)])),
    ShortLabel = gsub(" ", " ", gsub(".*: \"s*|\".*", "", ll[grepl("\"ShortLabel\":", ll)])),
    Addr_type = gsub(" ", " ", gsub(".*: \"s*|\".*", "", ll[grepl("\"Addr_type\":", ll)])),
    Type = gsub(" ", " ", gsub(".*: \"s*|\".*", "", ll[grepl("\"Type\":", ll)])),
    PlaceName = gsub(" ", " ", gsub(".*: \"s*|\".*", "", ll[grepl("\"PlaceName\":", ll)])),
    AddNum = gsub(" ", " ", gsub(".*: \"s*|\".*", "", ll[grepl("\"AddNum\":", ll)])),
    Address = gsub(" ", " ", gsub(".*: \"s*|\".*", "", ll[grepl("\"Address\":", ll)])),
    Block = gsub(" ", "", gsub(".*: \"s*|\".*", "", ll[grepl("\"Block\":", ll)])),
    Sector = gsub(" ", " ", gsub(".*: \"s*|\".*", "", ll[grepl("\"Sector\":", ll)])),
    Neighborhood = gsub(" ", " ", gsub(".*: \"s*|\".*", "", ll[grepl("\"Neighborhood\":", ll)])),
    District = gsub(" ", " ", gsub(".*: \"s*|\".*", "", ll[grepl("\"District\":", ll)])),
    City = gsub(" ", " ", gsub(".*: \"s*|\".*", "", ll[grepl("\"City\":", ll)])),
    MetroArea = gsub(" ", " ", gsub(".*: \"s*|\".*", "", ll[grepl("\"MetroArea\":", ll)])),
    Subregion = gsub(" ", " ", gsub(".*: \"s*|\".*", "", ll[grepl("\"Subregion\":", ll)])),
    Region = gsub(" ", " ", gsub(".*: \"s*|\".*", "", ll[grepl("\"Region\":", ll)])),
    Territory = gsub(" ", " ", gsub(".*: \"s*|\".*", "", ll[grepl("\"Territory\":", ll)])),
    Postal = gsub(" ", " ", gsub(".*: \"s*|\".*", "", ll[grepl("\"Postal\":", ll)])),
    PostalExt = gsub(" ", " ", gsub(".*: \"s*|\".*", "", ll[grepl("\"PostalExt\":", ll)])),
    CountryCode = gsub(" ", " ", gsub(".*: \"s*|\".*", "", ll[grepl("\"CountryCode\":", ll)]))
  )

  esri = x[x[, 1] != "",]
  esri = as.data.frame(t(esri), stringsAsFactors = F)
  esri[['lon']] = as.numeric(pt$lon)
  esri[['lat']]  = as.numeric(pt$lat)


# OSM Rgeocode ------------------------------------------------------------

  URL = paste0("https://nominatim.openstreetmap.org/reverse?format=xml&lat=",
               pt$lat,
               "&lon=",
               pt$lon,
               "&zoom=18&addressdetails=1")

  xx = xml2::read_xml(file(URL))
  xx = xml2::xml_children(xx)

  ll = xml2::xml_attrs(xx[1] )

  fin = as.data.frame(t(ll[[1]]), stringsAsFactors = F)

  y = as.character(xx[2])

  val = gsub("<.*?>", "", y)
  val = unlist(strsplit(val, "\n"))
  val = val[val != ""]
  val = trimws(val)

  nam = gsub(">.*?<", " ", y)
  nam = gsub("/", "", nam)
  nam = unlist(strsplit(nam, " "))
  nam = nam[duplicated(nam)]

  val = as.data.frame(t(val), stringsAsFactors = F)
  names(val) = nam

  val[["place_id"]] = fin$place_id
  val[["osm_type"]] = fin$osm_type
  val[["osm_id"]] = fin$osm_id
  val[["lat"]] = fin$lat
  val[["lon"]] = fin$lon
  val[["bb"]] = fin$boundingbox

  osm = val

  tmp = c(osm, esri)

  tmp = tmp[!duplicated(tmp)]

  tmp = as.data.frame(tmp, stringsAsFactors = F)

  tmp = tmp[!(names(tmp) %in% c("lat.1", "lon.1", "country_code","Neighborhood", "shorlabel"))]
  names(tmp) = tolower(names(tmp))

  bb.tmp = unlist(strsplit(tmp$bb, ","))

  tmp$bb = paste(bb.tmp[3], bb.tmp[4], bb.tmp[1], bb.tmp[2], sep = ",")

  class(tmp) <- c("geoloc", class(tmp))

  return(tmp)
}



