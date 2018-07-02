#' Find your Lat, long from IP Address
#'
#' @description
#' Not a good idea for reproducable code but helpful for finding and recording your location
#'
#' @seealso \code{getClipUnit}
#' @seealso \code{getAOI}
#'
#' @examples
#' \dontrun{
#' # Find your Location
#'
#' my.location = findLatLong()
#'
#' # Use with \emph{clip_unit} calls
#'
#' usgs = findUSGS(clip_unit = list(findLatLong(), 20, 20))
#' explore(usgs)
#'
#' # Use with find closest functions:
#'
#' ap = findClosestAirports(location = findLatLong(), number = 5)
#' explore()
#'
#'}
#' @return
#'
#' A lat, long pair \code{data.frame} Object
#'
#' @export
#' @author
#' Mike Johnson

findLatLong = function(){

  ret <- rjson::fromJSON(readLines('http://freegeoip.net/json/', warn=FALSE))
  coord = data.frame(lat = ret$latitude, lon = ret$longitude)

return(coord)
}



