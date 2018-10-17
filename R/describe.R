#' @title Describe an AOI
#' @description Describe a spatial, raster or sf object in terms of a reproducable clip area (e.g. \code{\link{getAOI}}) parmaters.
#' @param AOI any spatial object (\code{raster}, \code{sf}, \code{sp}).
#' @param full if TRUE, reverse geocoding descriptions returned, else just lat, lon, width, height, and origin (default = FALSE)
#' @return a data.frame of AOI descriptors including (at minimum):
#' \describe{
#'   \item{lat}{the AOI center latitude }
#'   \item{lon}{the AOI center longitude}
#'   \item{height}{ height in (miles)}
#'   \item{width}{width in(miles)}
#'   \item{origin}{AOI origin}
#' }
#' @export
#' @author Mike Johnson
#' @examples
#' \dontrun{
#'  AOI = getAOI("UCSB") %>% describe()
#'
#'  ```
#'  lat     :	34.41456
#'  lon     :	-119.8605796
#'  height  :	1
#'  width   :	3
#'  origin  :	center
#'  ```
#'
#'  AOI = getAOI("UCSB") %>% describe(full = TRUE)
#'
#'  ```
#'  lat     :	34.41456
#'  lon     :	-119.8605796
#'  height  :	1
#'  width   :	3
#'  origin  :	center
#'  name    :	6650 Abrego Rd, Goleta, California, 93117
#'  area    :	3 square miles
#'  ```
#' }

describe = function(AOI, full = FALSE){

  if(checkClass(AOI, 'sf')){ AOI = sf::as_Spatial(AOI)}
  if(checkClass(AOI, 'raster')){ AOI = getBoundingBox(AOI)}

  latCent = mean(AOI@bbox[2,])

  df = data.frame(
    lat = latCent,
    lon = mean(AOI@bbox[1,]),
    height  = round(69 * (abs(AOI@bbox[2,1] - AOI@bbox[2,2])), 0),
    width   = round(69 * cos(latCent * pi/180)*(abs(AOI@bbox[1,1] - AOI@bbox[1,2])), 0),
    origin  = "center",
    stringsAsFactors = F
    )

  if(full) {
    rc = revgeocode(point = c(df$latCent, df$lngCent))
    if (!is.null(rc$match_addr)) {
      df[["name"]]    = rc$match_addr
    } else if (!is.null(rc$city)) {
      df[["name"]]   = rc$city
    } else if (!is.null(rc$county)) {
      df[["name"]] = rc$county
    } else {
      df[["name"]] = rc[1]
    }
    df[['area']] = df$height * df$width
  }

  cat("AOI Parameters:\n")

  for (i in 1:NCOL(df)) {
    if (names(df)[i] %in% c("height", "width")) {
      ext = "miles"
    } else {
      ext = NULL
    }
    if (names(df)[i] %in% 'area') {
      ext = "square miles"
    } else {
      ext = NULL
    }
    cat(paste0("\n", names(df)[i], paste(rep(
      " ", 8 - nchar(names(df)[i])
    ), collapse = ""), ":\t"))
    cat(paste(df[i], ext))
  }

  cat("\n\n")
  return(df)

}





