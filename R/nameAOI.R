#' A function for returning a text string name of AOI
#'
#' @param state a character string. Can be full name or state abbriviation
#' @param county a character string. Can be full name or state abbriviation
#' @param clip can be provided as a shapefile or as a vector defineing centroid and bounding box diminsion
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
#' @author Mike Johnson
#'

nameAOI = function(state = NULL,
                   county = NULL,
                   clip = NULL) {
  unit = NULL

  if (!is.null(clip)) {
    unit = nameClip(clip)
  }

  if (all(!is.null(state), is.null(county))) {

    for (i in seq_along(state)) {
      if (nchar(state[i]) == 2) {
        unit = append(unit, stats::setNames(AOI::stateName, AOI::stateAbb)[state[i]])
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
    county_map = vector(mode = 'character')

    for (i in seq_along(state)) {
      if (nchar(state[i]) == 2) {
        states = append(states, stats::setNames(AOI::stateName, AOI::stateAbb)[state[i]])
      } else{
        states = append(states, simpleCap(tolower(state[i])))
      }
    }

    for (i in 1:length(county)) {
      county_map = append(county_map, simpleCap(tolower(county[i])))
    }

    if (length(county_map) > 1) {
      county_map[length(county_map)] = paste("and", tail(county_map, n = 1))
    }

    county_map = paste(county_map, collapse = ', ')

    unit = paste0("boundary of ", county_map, " County, ", states)
  }
  return(unit)
}


