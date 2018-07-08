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

  x = FALSE

  trash <-  capture.output(

    while( !isTRUE(x)){

                    tryCatch({
                      suppressMessages( loc <- dismo::geocode(name, output = 'latlon') )
                      x = TRUE
                    }, error = function(e){x = FALSE}
                  )
    }
  )


  rm(trash)

  location = data.frame(lat = loc$lat,
                        lon = loc$lon)

  return(location)

}


