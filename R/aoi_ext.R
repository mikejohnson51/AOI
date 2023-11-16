#' AOI extent
#'
#' Build an extent surrinding by location point (longitude, latitude) based on a width and height.
#'
#'
#' @param geo an origion specificed by a name
#' @param xy a orign specified as a numeric vector
#' @param wh width and height (can be a single number) in units (see units arg)
#' @param units units of wh expansion
#' @param crs output crs
#' @param bbox return bbox object?
#' @return vector or sf object
#' @export

aoi_ext = function(geo = NULL, xy = NULL, wh = NULL, units = default_units,
                   crs = default_crs, bbox = FALSE){

  if(!is.null(geo) & is.null(wh)){
    out = geocode(geo, pt = TRUE)
  }

  if(!is.null(geo) & !is.null(wh)){
    xy = geocode(geo, xy = TRUE)
    if(length(wh) == 1){ wh = c(wh, wh) }
    out = .domain(xy, wh, units, crs, bbox)
  }

  if(!is.null(xy) & is.null(wh)){
    out = st_point(x = xy, dim = "XY") %>%
      st_sfc(crs = 4326) %>%
      st_transform(crs)
  }

  if(!is.null(xy) & !is.null(wh)){
    if(length(wh) == 1){ wh = c(wh, wh) }
    out = .domain(xy, wh, units, crs, bbox)
  }

  out

}


#' Build Domain
#' @inheritParams aoi_ext
#' @return vector or sf object

.domain = function(xy, wh, units = default_units, crs = default_crs, bbox = FALSE){

  projection <- sprintf("+proj=%s +lon_0=%f +lat_0=%f +datum=WGS84", "laea", xy[1], xy[2])

  pt = st_point(x = xy, dim = "XY") %>%
    st_sfc(crs = crs) %>%
    st_transform(projection)

  w = wh[1]
  units(w) <- units
  w = as.numeric(set_units(w, "metre"))

  h = wh[2]
  units(h) <- units
  h = as.numeric(set_units(h, "metre"))

  bb  = c(xmin = as.numeric(xy[1] - w),
            xmax = as.numeric(xy[1] + w),
            ymin = as.numeric(xy[2] - h),
            ymax = as.numeric(xy[2] + h))

  xx =  st_bbox(bb) %>%
    st_as_sfc() %>%
    st_set_crs(projection) %>%
    st_transform(crs)

  if(!bbox){
    return(st_bbox(xx))
  } else {
    return(xx)
  }
}

#' Materialize Grid from File or inputs
#' @param ext extent (xmin, xmax, ymin, ymax) in some coordinate system
#' @param dim dimension (number of columns, number of rows)
#' @param in_crs projection of input ext
#' @param out_crs projection of output object
#' @param spatrast should a SpatRaster object be returned? Default is FALSE
#' @param fillValue in spatrast is TRUE, what values should fill the object
#' @param showWarnings should warnings be shown?
#' @return list or SpatRaster object
#' @export

discritize = function (ext = NULL,
                       dim = default_dim,
                       in_crs = default_crs,
                       out_crs = default_crs,
                       spatrast = FALSE,
                       fillValue = NULL,
                       showWarnings = TRUE) {


   if (is.null(ext)) { stop("ext required.") }

   tmp_crs = tryCatch({st_crs(ext)}, error = function(e){ NA })

   if(!is.na(tmp_crs)){
     in_crs = tmp_crs
   } else {
      if(in_crs == default_crs & showWarnings){
        warning('Assuming the input is in CRS 4326', call. = FALSE)
      }
    }

   projection = st_crs(out_crs)

   ext = suppressWarnings({
     bbox_get(ext) %>%
     st_set_crs(in_crs) %>%
     st_transform(projection$proj4string) %>%
     st_bbox()
   })

   ext = ext[c(1,3,2,4)]

   xl  <- diff(ext[c(1,2)])
   yl  <- diff(ext[c(3,4)])
   asp <- xl/yl * ifelse(st_is_longlat(projection$proj4string), cos(mean(yl) * pi/180), 1)

   dims <- as.numeric(round(dim * sort(c(1, asp))))

  if(spatrast){

    check_pkg('terra')

    r = terra::rast(terra::ext(ext),
                    nrows = dims[2],
                    ncols = dims[1],
                    crs = projection$proj4string)

    if(!is.null(fillValue)){ r[] = fillValue }

  } else {
    r = list(extent = ext,
         dimension =  dims,
         projection = projection$proj4string)
  }

  r
}


