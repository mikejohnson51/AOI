% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/aoi_utilities.R
\name{aoi_buffer}
\alias{aoi_buffer}
\title{Buffer AOI}
\usage{
aoi_buffer(AOI, d, km = FALSE)
}
\arguments{
\item{AOI}{a spatial, raster or simple features object}

\item{d}{\code{numeric}.The distance by which to modify each edge}

\item{km}{\code{logical}. If \code{TRUE} distances are in kilometers, default is \code{FALSE} with distances in miles}
}
\value{
a spatial geometry of the same class as the input AOI (if Raster sp returned)
}
\description{
Add or subtract a uniform distance to/from a spatial object in either miles or kilometers.
}
\examples{
\dontrun{
 # get an AOI of 'Garden of the Gods' and add a 2 mile buffer
    AOI = aoi_get("Garden of the Gods") \%>\% modify(2)

 # get an AOI of 'Garden of the Gods' and add a 2 kilometer buffer
    getAOI("Garden of the Gods") \%>\% modify(2, km = TRUE)

 # get and AOI for Colorado Springs and subtract 3 miles
    getAOI("Colorado Springs") \%>\% modify(-3)
}
}
