#' Provide the plain-english description of an AOi
#'
#' @description This function is a mirror of \code{\link{getAOI}} but instead of returning a \code{SpatilaPolygons} object,
#' returns a plain-english description of the AOI. (eg: 'AOI defined as a 10 mile tall by 10 mile wide region centered on (the) UCSB')
#'
#' @param state     \code{character}.  Full name or two character abbriviation. Not case senstive
#' @param county    \code{character}.  County name(s). Requires \code{state} input. Not case senstive
#' @param clip      \code{Spatial} object, a \code{Raster} object, or a \code{list} (see details and \code{\link{getClip}})
#' @param km       \code{logical}. If \code{TRUE} distance are in kilometers,  default is \code{FALSE} and with distances in miles
#'
#' @examples
#' \dontrun{
#' nameAOI(state = "CA")
#'}
#' @return A character string
#'
#' @export
#' @seealso \code{\link{nameClip}}
#'
#' @author Mike Johnson
#'

nameAOI = function(state = NULL,
                   county = NULL,
                   clip = NULL,
                   km = FALSE) {

  if (!is.null(clip)) {
    unit = nameClip(clip, km = km)
  } else {

    states_name = vector(mode = 'character')

    for (i in seq_along(state)) {
          if(nchar(state[i]) == 2){states_name[i] = AOI::states$state_name[which(AOI::states$state_abbr == state[i])]
        } else {
        states_name[i] = simpleCap(state[i])
      }
    }

  if (length(state) > 1) {
        states_name[length(states_name)] = paste("and", tail(states_name, n = 1))
        states_name = paste(states_name, collapse = ", ")
  }


  if(is.null(county)){
    unit = paste0("boundary of ", states_name)

  } else {

    county_map = vector(mode = 'character')
    noun = "county"

    if(any(county == 'all')){
      county_map = 'all'
      noun = 'counties'

      } else {
    for (i in 1:length(county)) {
      county_map[i] = AOI::simpleCap(tolower(county[i]))
    }
    }

    if (length(county_map) > 1) {
      county_map[length(county_map)] = paste("and", tail(county_map, n = 1))
    }

    county_map = paste(county_map, collapse = ', ')

    unit = paste("boundary of", county_map, noun, states_name)
  }
  }
  return(unit)
}



