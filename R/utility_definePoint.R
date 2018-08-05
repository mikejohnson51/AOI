definePoint = function(point, geo = FALSE, coords = TRUE){

  if(any(class(point) == "sf")){
    pts = sf::st_coordinates(point)
    colnames(pts) = c("lon", "lat")
    pts = data.frame(pts)
  }else if(class(point) == "character"){

    pts = AOI::getPoint(point)

   if(geo){point = sf::st_as_sf(x = pts, coords = c("lon", "lat"), crs = as.character(AOI::aoiProj))}

  }else if(class(point) %in% c("data.frame", "numeric")){
    pts = data.frame(lat = point[1], lon = point[2])
    if(geo){point = sf::st_as_sf(x = pts, coords = c("lon", "lat"), crs = as.character(AOI::aoiProj))}
  }


  if(all(geo, coords)){
  return(list(coords = pts, geo = point))
  } else if(geo) {return(point)
  } else if(coords){return(pts)}

}

