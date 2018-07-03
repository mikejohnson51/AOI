#' A function for returning a text string name of AOI
#'
#' @param state a character string. Can be full name or state abbriviation
#' @param county a character string. Can be full name or state abbriviation
#' @param clip_unit can be provided as a shapefile or as a vector defineing centroid and bounding box diminsion
#'
#' @examples
#' \dontrun{
#' nameAOI(state = "CA")
#'}
#' @return
#'
#' A character string
#'
#' @export
#'
#' @author
#'
#' Mike Johnson
#'

nameAOI = function(state = NULL,
                   county = NULL,
                   clip_unit = NULL) {
  unit = NULL

  if (!is.null(clip_unit)) {
    unit = name.clip.unit(clip_unit)
  }

  if (all(!is.null(state), is.null(county))) {

    for (i in seq_along(state)) {
      if (nchar(state[i]) == 2) {
        unit = append(unit, stats::setNames(AOI::state.name, AOI::state.abb)[state[i]])
      } else{
        unit = append(unit, simpleCap(tolower(state[i])))
      }
    }

    if (length(unit) > 1) {
      unit[length(unit)] = paste("and", tail(unit, n = 1))
    }

    unit = paste0("boundary of ", paste(unit, collapse = ", "))
  }

  if (!is.null(county)) {

    states = vector(mode = 'character')
    county.map = vector(mode = 'character')

    for (i in seq_along(state)) {
      if (nchar(state[i]) == 2) {
        states = append(states, stats::setNames(AOI::state.name, AOI::state.abb)[state[i]])
      } else{
        states = append(states, simpleCap(tolower(state[i])))
      }
    }

    for (i in 1:length(county)) {
      county.map = append(county.map, simpleCap(tolower(county[i])))
    }

    if (length(county.map) > 1) {
      county.map[length(county.map)] = paste("and", tail(county.map, n = 1))
    }

    county.map = paste(county.map, collapse = ', ')

    unit = paste0("boundary of ", county.map, " County, ", states)
  }
  return(unit)
}


