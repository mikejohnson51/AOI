describe = function(AOI){

  latCent = mean(AOI@bbox[2,])

  df = data.frame(

    latCent = latCent,
    lngCent = mean(AOI@bbox[1,]),
    height = round(69 * (abs(AOI@bbox[2,1] - AOI@bbox[2,2])), 0),
    width = round(69 * cos(latCent * pi/180)*(abs(AOI@bbox[1,1] - AOI@bbox[1,2])), 0),
    origin = "center",
    stringsAsFactors = F)

  df[["name"]] = revGeo(c(df$latCent, df$lngCent))[1,1]

  cat("AOI Parameters:\n")

  for(i in 1:NCOL(df)){

    if(names(df)[i] %in% c("height", "width")){ ext = "miles" } else {ext = NULL}

    cat(paste0("\n", names(df)[i], paste(rep(" ", 8 - nchar(names(df)[i])), collapse = ""), ":\t"))
    cat(paste(df[i], ext))
  }

  return(AOI)

}

