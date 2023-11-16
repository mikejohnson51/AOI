#' @title Get Area of Interest (AOI) geometry
#' @description Generate a spatial geometry from:
#' @param x \code{sf}, or a \code{Spat*} object
#' @param country \code{character}. Full name, ISO 3166-1 2 or 3 digit code.
#'                Not case sensitive. Data comes from Natural Earth.
#' @param state \code{character}. Full name or two character abbreviation.
#'              Not case sensitive. If \code{state = 'conus'}, the lower 48
#'              states will be returned. If \code{state = 'all'}, all states
#'              will be returned.
#' @param county \code{character}. County name(s). Requires \code{state} input.
#'               Not case sensitive If 'all' then all counties in a state
#'               are returned
#' @param fip a 2 or 5 digit US fip code
#' @param zipcode a US zip code. Will return a centroid.
#' @param union \code{logical}. If TRUE objects are unioned into a single object
#' @return a sf geometry projected to \emph{EPSG:4326}.
#' @export
#' @examples
#' \dontrun{
#' # Get AOI for a country
#' aoi_get(country = "Brazil")

#' # Get AOI defined by a state(s)
#' aoi_get(state = "CA")
#' aoi_get(state = c("CA", "nevada"))
#'
#' # Get AOI defined by all states, or the lower 48
#' aoi_get(state = "all")
#' aoi_get(state = "conus")
#'
#' # Get AOI defined by state & county pair(s)
#' aoi_get(state = "California", county = "Santa Barbara")
#' aoi_get(state = "CA", county = c("Santa Barbara", "ventura"))
#'
#' # Get AOI defined by state & all counties
#' aoi_get(state = "California", county = "all")
#' }

aoi_get <- function(x = NULL,
                    country = NULL,
                    state = NULL,
                    county = NULL,
                    fip = NULL,
                    zipcode = NULL,
                    union = FALSE) {

  meta <- list_states()

  if(all(is.null(x),
         is.null(country),
         is.null(state),
         is.null(county),
         is.null(fip),
         is.null(zipcode))) {
    stop("All entries cannot be NULL.")
  }


  # Error Catching
  if (is.null(country)) {
    if (!is.null(state)) {

      for (value in state) {
        if (!is.character(value)) { stop("State must be a character value.") }

        if (!(toupper(value) %in% c(
          toupper(meta$state_abbr),
          toupper(meta$name),
          toupper(meta$region),
          "CONUS",
          "ALL"
        ))) {
          stop(paste(
            "State not recognized.",
            "Full names, regions, or abbreviations can be used."
          ))
        }
      }
    } else {
      if (!is.null(county)) {
        stop("The use of 'county' requires a 'state' parameter.")
      }
    }
  }

  shp <- if (is.null(x)) {

    if(!is.null(zipcode)){

      print(zipcode)
      locs <- zipcodes[match(as.numeric(zipcode), zipcodes$zipcode), ]
      print(locs)
      failed <- zipcode[!zipcode %in% locs$zip]

      if (length(failed) > 0 & all(is.na(locs$lat))) {
        stop("Zipcodes ", paste(failed, collapse = ", "), " not found.")
      } else if (length(failed) > 0 ){
        warning("Zipcodes ", paste(failed, collapse = ", "), " not found.")
        locs = locs[!is.na(locs$zipcode),]
      }

      st_as_sf(locs, coords = c("lon", "lat"), crs = 4269)  %>%
        rename_geometry("geometry")

    } else {
      getFiat(country = country, state = state, county = county, fip = fip)
    }

  } else if (any(
    inherits(x, "SpatRaster"),
    inherits(x, "Spatial"),
    inherits(x, "sf")
  )) {

    st_bbox(x) %>%
      sf::st_as_sfc() %>%
      st_as_sf() %>%
      st_transform(4326) %>%
      rename_geometry("geometry")

  }  else {
    stop()
  }


  # Return AOI
  if (union) {
    st_union(shp) %>%
      st_as_sf() %>%
      rename_geometry("geometry")
  } else {
    shp
  }
}
