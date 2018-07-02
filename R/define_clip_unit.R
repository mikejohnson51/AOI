#' Interpret a clip unit from a user input
#'
#' @param clip_unit a user supplied input
#'
#' @return a list of features defining the AOI
#' @author Mike Johnson
#' @export

define.clip.unit = function(clip_unit) {
  #------------------------------------------------------------------------------#
  # Clip Unit Defintion  (getClipUnit() for 3,4, or 5 inputs)                    #
  #------------------------------------------------------------------------------#

  if (grepl(
    pattern = "Spatial",
    class(clip_unit),
    ignore.case = T,
    fixed = F
  )) {
    x = mean(clip_unit@bbox[1, ])
    y = mean(clip_unit@bbox[2, ])

    location <- c(y, x)
    h        <- round(abs(clip_unit@bbox[2, 1] - clip_unit@bbox[2, 2]) * 69, 0)
    w        <- round((abs(clip_unit@bbox[1, 1] - clip_unit@bbox[1, 2]) * 69) * (cos(y * pi / 180)), 0)
    o        <- 'center'
  }

  if (grepl(
    pattern = "Raster",
    class(clip_unit),
    ignore.case = T,
    fixed = F
  )) {
    e = raster::extent(clip_unit)
    x = mean(e[1:2])
    y = mean(e[3:4])

    location <- c(y, x)
    h        <- round(abs(e[4] - e[3]) * 69, 0)
    w        <- round((abs(e[2] - e[1]) * 69) * (cos(y * pi / 180)), 0)
    o        <- 'center'
  }

  # AOI defined by location and bounding box width and height

  if (length(clip_unit) == 3) {
    if (is.numeric(clip_unit[[1]])) {
      p <- clip_unit[[1]]
      clip_unit[[4]] <- clip_unit[[3]]
      clip_unit[[3]] <- clip_unit[[2]]
      clip_unit[[2]] <- p[2]
      clip_unit[[1]] <- p[1]

    } else if (!any(is.character(clip_unit[[1]]),
                    is.numeric(clip_unit[[2]]),
                    !is.numeric(clip_unit[[3]]))) {
      stop(
        "A clip_unit with length 3 must be defined by:
        (1) A name (i.e 'UCSB', 'The Walmart near the National Water Center') (character)
        (2) A bound box height (in miles) (numeric)
        (3) A bound box width (in miles) (numeric)"
      )
    } else {
      location <- clip_unit[[1]]
      h        <- clip_unit[[2]]
      w        <- clip_unit[[3]]
      o <- 'center'
    }
  }

  # AOI defined by (centroid lat, long, and bounding box width and height) or (loaction, width, height, origin)

  if (length(clip_unit) == 4) {
    if (all(
      all(
        is.numeric(clip_unit[[1]]),
        is.numeric(clip_unit[[2]]),
        is.numeric(clip_unit[[3]]),
        is.numeric(clip_unit[[4]])
      ),
      all(
        !is.numeric(clip_unit[[1]]),
        is.numeric(clip_unit[[2]]),
        is.numeric(clip_unit[[3]]),
        !is.numeric(clip_unit[[4]])
      )
    )) {
      stop(
        "A clip_unit with length 4 must be defined by:
        (1) A latitude (numeric)
        (2) A longitude (numeric)
        (3) A bound box height (in miles) (numeric)
        (4) A bound box width (in miles) (numeric)

        or

        (1) A location (character)
        (2) A bound box height (in miles) (numeric)
        (3) A bound box width (in miles) (numeric)
        (3) A bound box origion (character)
        "
      )

    } else if (all(
      is.numeric(clip_unit[[1]]),
      is.numeric(clip_unit[[2]]),
      is.numeric(clip_unit[[3]]),
      is.numeric(clip_unit[[4]])
    )) {
      if (!(-14.4246950943  <= clip_unit[[1]] &&
            clip_unit[[1]] <= 71.4395725902)) {
        stop("Latitude must be vector element 1 and within: (-90 <= x <= 90)")
      }

      if (!(-179.229655487 <= clip_unit[[2]] &&
            clip_unit[[2]] <= 179.856674735)) {
        stop("Longitude must be vector element 2 and within: (-180 <= x <= 180)")
      }

      location <- c(clip_unit[[1]], clip_unit[[2]])
      h      <- clip_unit[[3]]
      w      <- clip_unit[[4]]
      o      <- "center"

    } else if (all(
      is.character(clip_unit[[1]]),
      is.numeric(clip_unit[[2]]),
      is.numeric(clip_unit[[3]]),
      is.character(clip_unit[[4]])
    )) {
      location <- clip_unit[[1]]
      h        <- clip_unit[[2]]
      w        <- clip_unit[[3]]
      o        <- clip_unit[[4]]

    }
  }

  # if AOI defined by lat, long, width, height, origin

  if (length(clip_unit) == 5) {
    if (all(
      is.numeric(clip_unit[[1]]),
      is.numeric(clip_unit[[2]]),
      is.numeric(clip_unit[[3]]),
      is.numeric(clip_unit[[4]]),
      is.character(clip_unit[[5]])
    )) {
      location <- c(clip_unit[[1]], clip_unit[[2]])
      h        <- clip_unit[[3]]
      w        <- clip_unit[[4]]
      o        <- clip_unit[[5]]
    }
  }

  return(list(
    location = location,
    h = h,
    w = w,
    o = o
  ))

  }
