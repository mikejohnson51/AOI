bbox_st = function(AOI){
  
  return(list(xmin = AOI@bbox[1,1],
         xmax = AOI@bbox[1,2],
         ymin = AOI@bbox[2,1],
         ymax = AOI@bbox[2,2]))
}





