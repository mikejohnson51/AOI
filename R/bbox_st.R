print.bb = function(x){
  cat("Bounding Box:\n")

  for(i in 1:NCOL(x)){
    cat(paste0("\n", names(x)[i], paste(rep(" ", 4 - nchar(names(x)[i])), collapse = ""), ":\t"))
    cat(paste(round(x[i], 4)))
  }

}

bbox_st = function(AOI){

  bb =  data.frame(xmin = AOI@bbox[1,1],
         xmax = AOI@bbox[1,2],
         ymin = AOI@bbox[2,1],
         ymax = AOI@bbox[2,2])

  class(bb) = c("bb", class(bb))

  return(bb)

}



