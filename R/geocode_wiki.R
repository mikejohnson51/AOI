#' @title Alternate Page Finder
#' @description Find linked pages to a wikipedia call
#' @param loc a wikipedia structured call
#' @param pts \code{logical}. If TRUE point geometery
#'            is appended to the returned list()
#' @return at minimum a data.frame of lat, long
#' @author Mike Johnson
#' @keywords internal
#' @export
#' @examples
#' \dontrun{
#' alt_page("Twin_towers")
#' }
#' @importFrom rvest read_html html_nodes html_attr html_text

alt_page <- function(loc, pt = FALSE) {

  tt <- rvest::read_html(paste0(
    "https://en.wikipedia.org/w/index.php?search=",
    loc,
    "&title=Special%3ASearch&go=Go"
  ))

  a <- rvest::html_nodes(tt, "a")

  url_ <- rvest::html_attr(a, "href")

  link_ <- rvest::html_text(a)

  df_new <- data.frame(urls = url_, links = link_)
  df_new <- df_new[!is.na(df_new$urls), ]
  df_new <- df_new[!is.na(df_new$links), ]
  df_new <- df_new[grepl("/wiki/", df_new$urls), ]
  df_new <- df_new[!grepl(":", df_new$urls), ]
  df_new <- df_new[!grepl("Main_Page", df_new$urls), ]
  df_new <- df_new[!grepl("Privacy_Policy", df_new$urls), ]
  df_new <- df_new[!grepl("Terms_of_use", df_new$urls), ]

  if(nrow(df_new) == 0) { df_new <- NULL }

  return(df_new)
}


#' @title Geocoding Events
#' @description A wrapper around the Wikipedia API to return
#'              geo-coordinates of requested inputs.
#' @param event \code{character}. a term to search for on wikipeida
#' @param pt \code{logical}. If TRUE point geometery is appended
#'           to the returned list()
#' @return aa data.frame of lat/lon coordinates
#' @export
#' @author Mike Johnson
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
#' @importFrom jsonlite fromJSON
#' @importFrom rvest read_html html_nodes html_table
#' @importFrom rnaturalearth ne_countries
#' @importFrom sf st_as_sf

geocode_wiki <- function(event = NULL, pt = FALSE) {

  loc <- gsub(" ", "+", event)

  u <- paste0(
    "https://en.wikipedia.org/w/api.php?action=opensearch&search=",
    loc,
    "&limit=1&format=json&redirects=resolve"
  )

  url <- unlist(jsonlite::fromJSON(u))
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

    coord_url <- paste0('https://en.wikipedia.org/w/api.php?action=query&prop=coordinates&titles=',
                         paste(call, collapse = "|"),
                         '&format=json')


    fin <- jsonlite::fromJSON(coord_url)

    extract = function(x){
      if(!is.null(x$coordinates)){
        data.frame(title = x$title, lat = x$coordinates$lat, lon = x$coordinates$lon)
      } else {
        NULL
      }
    }

    df = do.call(rbind, lapply(fin$query$pages, extract))

    if (is.null(df)) {
      infobox <-
        rvest::read_html(url, header = FALSE) |>
        rvest::html_nodes(xpath = '//table[contains(@class, "infobox")]')

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
        y <- as.data.frame(
          rvest::html_table(infobox[1], header = F)[[1]],
          stringsAsFactors = FALSE
        )
        search <- y$X2[which(y$X1 == "Location")]
      }

      if (length(search) == 0) {
        search <- y$X2[which(y$X1 == "Headquarters")]
      }

      if (length(search) == 0) {
        meta <- list_states()
        countries <- rnaturalearth::ne_countries(returnclass = "sf")
        y <- y[y$X1 != y$X2, ]
        x <- y[grepl(tolower(paste0(c(meta$name, countries$name), collapse = "|")), tolower(y$X2)), ]

        all <- strsplit(gsub(", ", ",", x[1, 2]), ",")[[1]]
        df <- list()
        for (i in seq_len(length(all))) {
          df[[i]] <- geocode(all[i], full = FALSE)
        }

        df <- cbind(all, do.call(rbind, df))

      } else {
        s1 <- noquote(unlist(strsplit(search, ", ")))
        df <- NULL
        i <- 0

        while (NROW(df) == 0) {
          i <- i + 1
          def <- gsub('/"', "", do.call(paste, list(s1[c(1:i)])))
          df <- geocode(def, full = TRUE)
        }
      }
    }
  }

  if (pt) {
    sf::st_as_sf(x = df, coords = c("lon", "lat"), crs = 4269)
  } else {
    data.frame(cbind(request = loc, df))
  }

}

