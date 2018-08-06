#' @title Geocode
#' @description Overwrite dismo::geocode to only return lat/long only, remove excessive print statements, and to retry on query errors.
#' @param name a \code{character} place name
#' @return a data.frame of lat,lon values
#' @export
#' @author Mike Johnson
#' @examples
#' \dontrun{
#' getPoint("UCSB")
#' }

getPoint = function(name = "UCSB") {

  x = FALSE

  trash <-  capture.output(
    while (!isTRUE(x)) {
    tryCatch({
      suppressMessages(loc <- dismo::geocode(name, output = 'latlon'))
      x = TRUE
    }, error = function(e) {
    })
  })

  rm(trash)

  location = data.frame(lat = loc$lat,
                        lon = loc$lon)
  return(location)

}

