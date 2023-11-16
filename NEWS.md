AOI 0.3.0 (2023-09)
=========================

### NEW FEATURES

  * Change original OpenStreetMap geocoder to `tidygeocoder` due to new restrictions 
  * Previously, we allowed the following for place based area requests:
       - c(GEO, distance, distance) --> POLYGON
       - c(lat, lng, distance, distance) --> POLYGON
      
  * We now support:
      - c(lat, lng) --> POINT
      - c(lat, lng, distance) --> POLYGON 
  
  * All of these have been moved from aoi_get to aoi_ext which uses:
      - geo
      - xy
      - wh 
      
  * materialize_grid from zonal was moved here and called discritize
  
  * Works with terra not raster objects

AOI 0.2.0 (2021-03)
=========================

### NEW FEATURES

  * `aoi_draw()` - Interactively draw an Area of Interest (AOI) using a `shiny` app.
