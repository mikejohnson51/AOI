print.geoloc <- function(x) {

  for(i in 1:NCOL(x)){
    cat(paste0("\n", names(x)[i], paste(rep(" ", 12 - nchar(names(x)[i])), collapse = ""), ":\t"))
    cat(paste(x[i]))
  }
}


#' @title Reverse Geocode
#' @description Describe a point using the ERSI server geocoding  and reverse geocoding functionalities
#' @param point a point provided a lat,long vector or data.frame; or a string
#' @return a data.frame of input point descriptions
#' @export
#' @author Mike Johnson
#' @examples
#' pt1 = revGeo("UCSB")
#' print(pt1)
#'
#' pt2 = revGeo(c(38,-115))
#' print(pt2)

revGeo = function(point) {
  pt = definePoint(point, geo = F)

  connectStr <-
    paste0(
      "http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/reverseGeocode",
      "?f=pjson&featureTypes=&location=",
      paste(pt$lon, pt$lat, sep = ",")
    )

  ll = readLines(connectStr, warn = F)

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

  xx = x[x[, 1] != "",]
  xxx = as.data.frame(t(xx), stringsAsFactors = F)
  xxx[['lon']] = as.numeric(pt$lon)
  xxx[['lat']]  = as.numeric(pt$lat)
  class(xxx) <- c("geoloc", class(xxx))

  return(xxx)

}





