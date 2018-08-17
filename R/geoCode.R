#' @title Geocoding
#'
#' @param location
#' @param pt
#' @param bb
#' @param server
#'
#' @return
#' @export
#'
#' @examples
geocode = function(location = NULL, pt = FALSE, bb = FALSE, server = "google"){

  b = any(c(pt, bb))

  if(b){ poi = list() } else { poi = vector() }

  for(i in location){

  if(server == 'google'){
    df = geocodeGoogle(location = i, pt = pt, bb = bb)
  }

  if(server == 'osm'){
    df = suppressWarnings( geocodeOSM(i, pt, bb) )
    if( length(df) < 2 ){ df = geocodeGoogle(i, pt, bb) }
  }

   if(b){ poi = df } else { poi = rbind(poi, df ) }
  }

  if(class(poi) != 'list'){
    if(NROW(poi) > 1){
      poi = as.data.frame(poi, stringsAsFactors = F)
      poi$name = location
    }
  }

  return(poi)
}



