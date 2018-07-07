#' Geocode a Point
#'
#' Overwrite the
#'
#' @param name a \code{character} place name
#'
#' @return a data.frame of lat,lon values
#' @export
#' @author Mike Johnson


getPoint = function(name = "UCSB") {

  trash <-  capture.output(
                    suppressMessages(
                      loc <- dismo::geocode(name, output = 'latlon')
                    )
                  )

  rm(trash)

  location = data.frame(lat = loc$lat,
                        lon = loc$lon)

  return(location)

}
