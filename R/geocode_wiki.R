#' @title Alternate Page Finder
#' @description Find linked pages to a wikipedia call
#' @param loc a wikipedia structured call
#' @param pts \code{logical}. If TRUE point geometery is appended to the returned list()
#' @return at minimum a data.frame of lat, long
#' @author Mike Johnson
#' @keywords internal
#' @export
#' @examples
#' \dontrun{
#' alt_page("Twin_towers")
#' }

alt_page = function(loc, pt = FALSE){

  tt = xml2::read_html(paste0('https://en.wikipedia.org/w/index.php?search=',
                              loc,
                              '&title=Special%3ASearch&go=Go') )

  url_ <- tt %>%
          rvest::html_nodes("a") %>%
          rvest::html_attr("href")

  link_ <- tt %>%
            rvest::html_nodes("a") %>%
            rvest::html_text()

  df.new = data.frame(urls = url_, links = link_)
  df.new = df.new[grepl("/wiki/",df.new$urls),]
  df.new = df.new[!grepl(":",df.new$urls),]
  df.new = df.new[!grepl("Main_Page",df.new$urls),]
  df.new = df.new[!grepl("Privacy_Policy",df.new$urls),]
  df.new = df.new[!grepl("Terms_of_use",df.new$urls),]
  df.new = df.new[1:10,]
  df.new = df.new[complete.cases(df.new),]
  if(NROW(df.new) == 0 ){df.new = NULL}

  return(df.new)
}


#' @title Geocoding Events
#' @description A wrapper around the Wikipedia API to return geo-coordinates of requested inputs.
#' @param event \code{character}. a term to search for on wikipeida
#' @param pt \code{logical}. If TRUE point geometery is appended to the returned list()
#' @return aa data.frame of lat/lon coordinates
#' @export
#' @author Mike Johnson
#' @examples
#' \dontrun{
#'    ## geocode an Agency
#'      geocode_wiki("NOAA")
#'
#'  ## geocode an event
#'      geocode_wiki("I have a dream speech")
#'
#'  ## geocode a n event
#'      geocode_wiki("D day")
#'
#'  ## geocode a product
#'      geocode_wiki("New York Times")
#'
#'  ## geocode an event
#'      geocode_wiki("Hurricane Harvey")
#'
#' }

geocode_wiki = function(event = NULL, pt = FALSE){

  loc =  gsub(" ", "+", event)
  u = paste0('https://en.wikipedia.org/w/api.php?action=opensearch&search=',
             loc,
             '&limit=1&format=json&redirects=resolve')

  url = unlist(jsonlite::fromJSON(u))
  url = url[grepl("http", url)]
  call = gsub("https://en.wikipedia.org/wiki/", "", url)

  if(length(call) == 0){
    df.new = alt_page(loc)
    message("'", event, "' not found...\nTry one of the following?\n\n", paste(df.new$links, collapse = ',\n'))
    return(df.new)
  } else {

    coord.url = paste0('https://en.wikipedia.org/w/api.php?action=query&format=json&prop=coordinates&titles=', call)

    fin = jsonlite::fromJSON(coord.url)

    df = data.frame(lat = unlist(fin$query$pages[[1]]$coordinates$lat), lon = unlist(fin$query$pages[[1]]$coordinates$lon))

    if(nrow(df) == 0){

      infobox <- url %>%
        xml2::read_html(header = FALSE) %>%
        rvest::html_nodes(xpath='//table[contains(@class, "infobox")]')

      if(length(infobox) == 0){
        df.new = alt_page(loc)
        message("'", event, "' not found...\nTry one of the following?\n\n", paste(df$links, collapse = ',\n'))
        return(df.new)
      } else {
        y = as.data.frame(rvest::html_table(infobox[1], header = F)[[1]], stringsAsFactors = FALSE)
        search = y$X2[which(y$X1 == 'Location')]
      }

      if(length(search) == 0){ search = y$X2[which(y$X1 == 'Headquarters')] }

      if(length(search) == 0){
        meta = list_states()
        countries = rnaturalearth::ne_countries(returnclass = "sf")
        y = y[y$X1 != y$X2,]
        x = y[grepl(tolower(paste0(c(meta$name, countries$name), collapse = "|")), tolower(y$X2)),]

        all = strsplit(gsub(", ", ",", x[1,2]), ",")[[1]]
        df = list()
        for(i in 1:length(all)){
          df[[i]] = geocode(all[i], full = FALSE)
        }

        df = cbind(all, do.call(rbind, df))
        df = df[complete.cases(df),]

      } else {
        s1 = noquote(unlist(strsplit(search, ", ")))
        df = NULL
        i = 0

        while(NROW(df) == 0){
          i = i + 1
          def = gsub('/"', "", do.call(paste, list(s1[c(1:i)])))
          df = geocode(def, full = TRUE)
        }
      }
    }
  }

    if(pt){
      points = sf::st_as_sf(x = df, coords = c('lon', 'lat'), crs = 4269)
      return(points)
    } else {
      df = cbind(request = loc, df) %>% data.frame()
      return(df)
    }
  #}
}





