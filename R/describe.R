#' @title Describe an AOI
#' @description Breaks a Spatial object into the features describing a reporducable clip area.
#' @param AOI a spatial, raster or sf object
#' @return a data.frame of AOI descriptors including
#' \describe{
#'   \item{latCent}{the AOI center latitude}
#'   \item{lngCent}{the AOI center longitude}
#'   \item{height}{ height in (miles)}
#'   \item{width}{width in(miles)}
#'   \item{origin}{AOI origin}
#'   \item{name}{Most descriptive geocoded name from \code{\link{revgeocode}}}
#' }
#' @export
#' @author Mike Johnson
#' @examples
#' \dontrun{
#'  AOI = getAOI(clip = list("UCSB", 10, 10)) %>% describe()
#'
#'  ```
#'  latCent :	34.4139629
#'  lngCent :	-119.848947
#'  height  :	10 miles
#'  width   :	10 miles
#'  origin  :	center
#'  name    :	93106, Santa Barbara, California
#'  ```
#'
#' }

describe = function(AOI){

  if(checkClass(AOI, 'sf')){ AOI = sf::as_Spatial(AOI)}
  if(checkClass(AOI, 'raster')){ AOI = getBoundingBox(AOI)}

  latCent = mean(AOI@bbox[2,])

  df = data.frame(

    latCent = latCent,
    lngCent = mean(AOI@bbox[1,]),
    height = round(69 * (abs(AOI@bbox[2,1] - AOI@bbox[2,2])), 0),
    width = round(69 * cos(latCent * pi/180)*(abs(AOI@bbox[1,1] - AOI@bbox[1,2])), 0),
    origin = "center",
    stringsAsFactors = F)

  rc = revgeocode(c(df$latCent, df$lngCent))

  if(!is.null(rc$match_addr)) { df[["name"]] = rc$match_addr
  } else if(!is.null(rc$city)) { df[["name"]] = rc$city
  } else if(!is.null(rc$county)) { df[["name"]] = rc$county
  } else { df[["name"]] = rc[1] }

  cat("AOI Parameters:\n")

  for(i in 1:NCOL(df)){

    if(names(df)[i] %in% c("height", "width")){ ext = "miles" } else {ext = NULL}

    cat(paste0("\n", names(df)[i], paste(rep(" ", 8 - nchar(names(df)[i])), collapse = ""), ":\t"))
    cat(paste(df[i], ext))
  }

  return(df)

}

