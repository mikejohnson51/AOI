#' @title Alternate Page Finder
#' @description Find linked pages to a wikipedia call
#' @param loc a wikipedia structured call
#' @return at minimum a data.frame of lat, long
#' @author Mike Johnson
#' @keywords internal
#' @export
#' @examples
#' \dontrun{
#' alt_page("Twin_towers")
#' }

alt_page = function(loc){
  tt = xml2::read_html(paste0('https://en.wikipedia.org/w/index.php?search=', loc, '&title=Special%3ASearch&go=Go') )

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
  return(df.new)
}


#' @title Geocoding Events
#' @description A wrapper around the Wikipedia API to return geo-coordinates of requested inputs.
#' @param event \code{character}. a term to search for on wikipeida
#' @return aa data.frame of lat/lon coordinates
#' @export
#' @author Mike Johnson
#' @examples
#' \dontrun{
#'    ## geocode an Agency
#'      geocode_wiki("NOAA")
#'
#'  ## geocode an event
#'      geocode_wiki(""Parkland Shooting")
#'
#'  ## geocode a n event
#'      geocode_wiki("Hurricane Harvey")
#'
#'  ## geocode a product
#'      geocode_wiki("New York Times")
#'
#'  ## geocode multiple points and generate a minimum bounding box of all locations and spatial points
#'      geocode_wiki(c("UCSB", "Goleta", "Santa Barbara"), bb = T, pt= T)
#' }

geocode_wiki = function(event = NULL){

  loc =  gsub(" ", "+", event)
  u = paste0('https://en.wikipedia.org/w/api.php?action=opensearch&search=', loc, '&limit=1&format=json&redirects=resolve')
  url = unlist(jsonlite::fromJSON(u))
  url = url[grepl("http", url)]
  call = gsub("https://en.wikipedia.org/wiki/", "", url)

  if(length(call) == 0){
    df.new = alt_page(loc)
    message("'", event, "' not found...\nTry one of the following?\n\n", paste(df.new$links, collapse = ',\n'))

  } else {

    coord.url = paste0('https://en.wikipedia.org/w/api.php?action=query&format=json&prop=coordinates&titles=', call)

    fin = jsonlite::fromJSON(coord.url)

    df = data.frame(lat = unlist(fin$query$pages[[1]]$coordinates$lat), lon = unlist(fin$query$pages[[1]]$coordinates$lon))

    if(NROW(df) == 0){

      infobox <- url %>%
        xml2::read_html(header = FALSE) %>%
        rvest::html_nodes(xpath='//table[contains(@class, "infobox")]')

      if(length(infobox) == 0){
        df = alt_page(loc)
        message("'", event, "' not found...\nTry one of the following?\n\n", paste(df$links, collapse = ',\n'))
      } else {
        y = as.data.frame(rvest::html_table(infobox[1], header = F)[[1]], stringsAsFactors = FALSE)
        search = y$X2[which(y$X1 == 'Location')]
      }

      if(length(search) == 0){
        search = y$X2[which(y$X1 == 'Headquarters')]
      }

      if(length(search) == 0){
        y = y[y$X1 != y$X2,]
        x = y[grepl(tolower(paste0(c( AOI::states$state_name, AOI::world$NAME), collapse = "|")), tolower(y$X2)),]
        df = AOI::geocode(strsplit(gsub(", ", ",", x[1,2]), ",")[[1]])
      } else {
        s1 = noquote(unlist(strsplit(search, ", ")))
        df = NULL
        i = 0

        while(NROW(df) == 0){
          i = i + 1
          def = gsub('/"', "", do.call(paste, list(s1[c(1:i)])))
          df = AOI::geocode(def)
        }
      }
    }
  }

  if(is.null(df)){ message("No data found")} else{ return(df) }
}





