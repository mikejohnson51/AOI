#' @title .geocode
#' @inheritParams geocode
#' @inherit geocode return

.geocode <- function(geo,
                     pt = FALSE,
                     bbox = FALSE,
                     all = FALSE,
                     method = default_method,
                     crs = default_crs) {

  request <- long <- lat <-  score <-  . <- NULL

  if (sum(pt, bbox, all) > 1) {
    stop("Only pt, bbox, or all can be TRUE. Leave others as FALSE")
  }

  if (!inherits(geo, "character")) {
    stop(
      paste(
        "",
        "Input geo is not a place name. ",
        "You might be looking for reverse geocodeing.",
        "Try: AOI::geocode_rev()",
        sep = "\n"
      )
    )
  }

  ret = suppressMessages({
    geo(
      geo,
      progress_bar = FALSE,
      method = method,
      full_results = TRUE,
      verbose = FALSE
    ) %>%
      mutate(request = geo) %>%
      select(request,
             x = long,
             y = lat,
             score,
             contains("_address"),
             contains("extent"))
  })

  if (all(is.na(ret$y))) {
    return(ret)
  }

  point <-
    st_as_sf(x = ret,
             coords = c("x", "y"),
             crs = 4326) %>%
    rename_geometry("geometry") %>%
    st_transform(crs) %>%
    mutate(x = sf::st_coordinates(.)[,1],
           y = sf::st_coordinates(.)[,2]) %>%
    select(-contains("extent"))

  if(nrow(point) > 1){
    bbs = bbox_get(point)
  } else {
    bbs = list()

    for (i in 1:nrow(ret)) {
      bbs[[i]] <-
        st_bbox(
          c(
            xmin = ret$extent.xmin[i],
            xmax = ret$extent.xmax[i],
            ymin = ret$extent.ymin[i],
            ymax = ret$extent.ymax[i]
          ),
          crs = 4326
        ) %>%
        st_as_sfc() %>%
        st_as_sf() %>%
        rename_geometry("geometry") %>%
        st_transform(crs)
    }

    bbs =  do.call(rbind, bbs)
    bbs$request = ret$request
    bbs = merge(bbs, st_drop_geometry(point))
  }

  if (pt)  { return(point) }
  if (bbox){ return(bbs) }
  if (all) {
    return(list(pt = point, bbox = bbs ))
  }

  return(st_drop_geometry(point))
}


#' @title Geocoding
#' @description
#' A wrapper around the tidygeocoding and Wikipedia services.
#' Users can request a data.frame (default), vector (xy = TRUE), point (pt = TRUE), and/or a bounding box (bbox = TRUE) representation of a place/location (geo) or event. One or more can be given at a time.
#'
#' If a single entitiy is requested, `geocode`
#' will provide a data.frame of lat/lon values and, if requested,
#' a  point object and the derived bounding box of the geo/event.
#'
#' If multiple entities are requested, the returned objects will
#' be a data.frame with columns for input name-lat-lon; if requested,
#' a POINT object will be returned.  Here, the bbox argument will return the
#' minimum bounding box of all place names.
#' @param geo \code{character}. Place name(s)
#' @param event \code{character}. a term to search for on Wikipedia
#' @param pt \code{logical}. If TRUE point geometry is created.
#' @param bbox \code{logical}. If TRUE bounding box geometry is created
#' @param xy \code{logical}. If TRUE a named xy numeric vector is created
#' @param all \code{logical}. If TRUE the point, bbox and xy representations are returned as a list
#' @param method the geocoding service to be used. See ?tidygeocoder::geocode
#' @param crs desired CRS. Defaults to AOI::default_crs
#' @return a data.frame, sf object, or vector
#' @export
#' @family geocode
#' @examples
#' \dontrun{
#' ## geocode a single locations
#' geocode("UCSB")
#'
#' ## geocode a single location and return a POINT object
#' geocode("UCSB", pt = TRUE)
#'
#' ## geocode a single location and derived bbox of location
#' geocode(location = "UCSB", bbox = TRUE)
#'
#' ## geocode multiple locations
#' geocode(c("UCSB", "Goleta", "Santa Barbara"))
#'
#' ## geocode multiple points and generate a minimum bounding box of all locations and spatial points
#' geocode(c("UCSB", "Goleta", "Santa Barbara"), bbox = T, pt = T)
#' }

geocode <- function(geo = NULL,
                    event = NULL,
                    pt = FALSE,
                    bbox = FALSE,
                    all = FALSE,
                    xy = FALSE,
                    method = default_method,
                    crs = default_crs) {



  if (!is.null(event)) {
    locs = list()

    suppressWarnings({
      locs$event <-  do.call(rbind, lapply(event, geocode_wiki)) %>%
        st_as_sf(coords = c("x", "y"), crs = 4326) %>%
        st_transform(crs)
    })

    if (pt | all | bbox) {
      locs$pt = st_as_sf(locs$event,
                         coords = c("x", "y"),
                         crs = 4326) %>%
        st_transform(crs)

      locs$event = NULL
    }

    if (bbox | all) {
      if (nrow(locs$pt) > 1) {
        locs$bbox = st_as_sf(merge(st_drop_geometry(locs$pt), bbox_get(locs$pt)))
      } else {
        locs$bbox = locs$pt
      }

      if (bbox) {
        locs$pt = NULL
      }
    }

    if (length(locs) == 1) {
      locs = locs[[1]]
    }
  }

  if (!is.null(geo)) {
    locs = .geocode(geo,
                    pt,
                    bbox,
                    all,
                    method,
                    crs = crs)
  }

  if (xy) {
    locs = c(locs$x,locs$y)
  }

  return(locs)
}

#' @title Alternate Page Finder
#' @description Find linked pages to a wikipedia call
#' @param loc a wikipedia structured call
#' @param pt \code{logical}. If TRUE point geometery
#'            is appended to the returned list()
#' @return at minimum a data.frame of lat, long
#' @examples
#' \dontrun{
#' alt_page("Twin_towers")
#' }
#' @importFrom rvest read_html html_nodes html_attr html_text

alt_page <- function(loc, pt = FALSE) {
  tt <- read_html(
    paste0(
      "https://en.wikipedia.org/w/index.php?search=",
      loc,
      "&title=Special%3ASearch&go=Go"
    )
  )

  a <- html_nodes(tt, "a")
  url_  <- html_attr(a, "href")
  link_ <- html_text(a)

  df_new <- data.frame(urls = url_, links = link_)
  df_new <- df_new[!is.na(df_new$urls),]
  df_new <- df_new[!is.na(df_new$links),]
  df_new <- df_new[grepl("/wiki/", df_new$urls),]
  df_new <- df_new[!grepl(":", df_new$urls),]
  df_new <- df_new[!grepl("Main_Page", df_new$urls),]
  df_new <- df_new[!grepl("Privacy_Policy", df_new$urls),]
  df_new <- df_new[!grepl("Terms_of_use", df_new$urls),]

  if (nrow(df_new) == 0) {
    df_new <- NULL
  }

  return(df_new)
}


#' @title Geocoding Events
#' @description A wrapper around the Wikipedia API to return
#'              geo-coordinates of requested inputs.
#' @param event \code{character}. a term to search for on wikipeida
#' @param pt \code{logical}. If TRUE point geometery is appended
#'           to the returned list()
#' @return a data.frame of lat/lon coordinates
#' @export
#' @family geocode
#' @examples
#' \dontrun{
#' ## geocode an Agency
#' geocode_wiki("NOAA")
#'
#' ## geocode an event
#' geocode_wiki("I have a dream speech")
#'
#' ## geocode a n event
#' geocode_wiki("D day")
#'
#' ## geocode a product
#' geocode_wiki("New York Times")
#'
#' ## geocode an event
#' geocode_wiki("Hurricane Harvey")
#' }

geocode_wiki <- function(event = NULL, pt = FALSE) {

  loc <- gsub(" ", "+", event)

  u <- paste0(
    "https://en.wikipedia.org/w/api.php?action=opensearch&search=",
    loc,
    "&limit=1&format=json&redirects=resolve"
  )

  url <- unlist(fromJSON(u))
  url <- url[grepl("http", url)]
  call <- gsub("https://en.wikipedia.org/wiki/", "", url)

  if (length(call) == 0) {
    df_new <- alt_page(loc)
    message(
      "'",
      event,
      "' not found...\nTry one of the following?\n\n",
      paste(df_new$links, collapse = ",\n")
    )

    return(df_new)

  } else {
    coord_url <-
      paste0(
        'https://en.wikipedia.org/w/api.php?action=query&prop=coordinates&titles=',
        paste(call, collapse = "|"),
        '&format=json'
      )


    fin <- fromJSON(coord_url)

    extract = function(x) {
      if (!is.null(x$coordinates)) {
        data.frame(
          title = x$title,
          lat = x$coordinates$lat,
          lon = x$coordinates$lon
        )
      } else {
        NULL
      }
    }

    df = do.call(rbind, lapply(fin$query$pages, extract))

    if (is.null(df)) {
      infobox <-
        read_html(url, header = FALSE) %>%
        html_nodes(xpath = '//table[contains(@class, "infobox")]')

      if (length(infobox) == 0) {
        df_new <- alt_page(loc)
        message(
          "'",
          event,
          "' not found...\nTry one of the following?\n\n",
          paste(df$links, collapse = ",\n")
        )
        return(df_new)
      } else {
        y <- as.data.frame(html_table(infobox[1], header = F)[[1]],
                           stringsAsFactors = FALSE)
        search <- y$X2[which(y$X1 == "Location")]
      }

      if (length(search) == 0) {
        search <- y$X2[which(y$X1 == "Headquarters")]
      }

      if (length(search) == 0) {
        meta <- list_states()
        countries <- ne_countries(returnclass = "sf")
        y <- y[y$X1 != y$X2,]
        x <-
          y[grepl(tolower(paste0(
            c(meta$name, countries$name), collapse = "|"
          )), tolower(y$X2)),]

        all <- strsplit(gsub(", ", ",", x[1, 2]), ",")[[1]]
        df <- list()
        for (i in seq_len(length(all))) {
          df[[i]] <- geocode(all[i])
        }

        df <- cbind(all, do.call(rbind, df))

      } else {
        s1 <- noquote(unlist(strsplit(search, ", ")))
        df <- NULL
        i <- 0

        while (nrow(df) == 0) {
          i <- i + 1
          def <- gsub('/"', "", do.call(paste, list(s1[c(1:i)])))
          df <- geocode(def)
        }
      }
    }
  }

  lookup <- c(y = "lat", x = "lon")

  df = df %>%
    rename(any_of(lookup))

  if (pt) {
    st_as_sf(x = df,
             coords = c("x", "y"),
             crs = default_crs)
  } else {
    data.frame(cbind(request = loc, df))
  }

}

#' @title Reverse Geocoding
#' @description
#' Describe a location using the ERSI and OSM reverse geocoding web-services.
#' This service provides traditional reverse geocoding (lat/lon to placename)
#' but can also be use to get more information about a place name. xy must contain geographic coordinates!
#' @inheritParams geocode
#' @inherit geocode return
#' @export
#' @family geocode
#' @examples
#' \dontrun{
#'  geocode_rev(xy = c(38,-115))
#' }

geocode_rev <- function(xy,
                        pt = FALSE,
                        method = default_method) {

  address <-  long <- lat <- NULL

  if (inherits(xy, "character")) {
    stop("Reverse geocoding opperates on numeric xy coordinates. Maybe try geocode?")
  } else if (length(xy) != 2) {
    stop("xy must be of length 2")
  } else if (inherits(xy, "numeric")) {
    tmp = reverse_geo(
      lat = xy[2],
      long = xy[1],
      method = method,
      progress_bar = FALSE,
      quiet = TRUE
    ) %>%
      select(address, x = long, y = lat)
  }

  if (pt) {
    tmp = st_as_sf(x = tmp,
                   coords = c("x", "y"),
                   crs = 4326)
  }

  return(tmp)
}
