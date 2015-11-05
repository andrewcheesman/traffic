# Creates the file 'spatial.txt' and 'ptl.RDA', a lookup for spatial data and the basis for the splndf's
# Decodes PolyLines and saves output as a spatial points dataframe
# need only be run when a spatial refresh is necessary - i.e. rarely

# library(sp)

data <- read.delim("/home/awc/Traffic_1/data.txt")

spat.1 <- data[,c(1,6,7,8,13)]
spat <- unique(spat.1)
spat[,c(3,4,5)] = apply(spat[,c(3,4,5)], 2, function(x) as.character(x))

# write.table(spat, "spatial.txt")

# Decoding Polylines
# From http://s4rdd.blogspot.com/2012/12/google-maps-api-decoding-polylines-for.html
decodeLine <- function(encoded){
  require(bitops)
  
  vlen <- nchar(encoded)
  vindex <- 0
  varray <- NULL
  vlat <- 0
  vlng <- 0
  
  while(vindex < vlen){
    vb <- NULL
    vshift <- 0
    vresult <- 0
    repeat{
      if(vindex + 1 <= vlen){
        vindex <- vindex + 1
        vb <- as.integer(charToRaw(substr(encoded, vindex, vindex))) - 63
      }
      
      vresult <- bitOr(vresult, bitShiftL(bitAnd(vb, 31), vshift))
      vshift <- vshift + 5
      if(vb < 32) break
    }
    
    dlat <- ifelse(
      bitAnd(vresult, 1)
      , -(bitShiftR(vresult, 1)+1)
      , bitShiftR(vresult, 1)
    )
    vlat <- vlat + dlat
    
    vshift <- 0
    vresult <- 0
    repeat{
      if(vindex + 1 <= vlen) {
        vindex <- vindex+1
        vb <- as.integer(charToRaw(substr(encoded, vindex, vindex))) - 63
      }
      
      vresult <- bitOr(vresult, bitShiftL(bitAnd(vb, 31), vshift))
      vshift <- vshift + 5
      if(vb < 32) break
    }
    
    dlng <- ifelse(
      bitAnd(vresult, 1)
      , -(bitShiftR(vresult, 1)+1)
      , bitShiftR(vresult, 1)
    )
    vlng <- vlng + dlng
    
    varray <- rbind(varray, c(vlat * 1e-5, vlng * 1e-5))
  }
  coords <- data.frame(varray)
  names(coords) <- c("lat", "lon")
  coords
}

# Removing a single polyline that gave errors when running locally - may be able to ignore in future
badcode <- ("cl}wFtbkaMfFiIdByBrD{DtAeAj@_@nA}@|BcAvBy@hBc@zDm@jBOrBY|C_@f@EpHk@|Is@????bIOrGa@xHcBvFyBtImDzHgDtBcAtCoApCgAbEqA~QuHxGqDbCUbCRjEcApEy@jGeAtEi@dBg@t@SdRyGzHwC|IcDbKuDdLeEnM}ExOwFzRsHnCoArGeEtOaQjGqMbCoJ|@{GDuIe@Sf")
spat_subs <- spat[spat$EncodedPolyLine!=badcode,]

rm(data, spat.1, spat, badcode)

# spat.dcdd.lst <- lapply(spat_subs$EncodedPolyLine,decodeLine)
# spat.dcdd.df <- do.call("rbind",spat.dcdd.lst)

for (i in (1:(length(spat_subs[,1])-1))) {
decode <- as.data.frame(lapply(spat_subs[i,4],decodeLine))
decode$linkId <- spat_subs[i,2]
decode$sqno <-seq_along(1:length(decode[,1]))
if(exists("cont")==F) {cont <- decode}
else {cont <- rbind(cont,decode)}
}

spatial_dcd <- cont[,c(3,4,1,2)]
rm(spat_subs, decode, cont, i)

save(spatial_dcd, file="/home/awc/Traffic_1/_spatial_dcd.RDA")

library(sp)
library(maptools)

# Using points-to-line function, from here:
# https://rpubs.com/walkerke/points_to_line

load(file="/home/awc/Traffic_1/_spatial_dcd.RDA")

points_to_line <- function(data, long, lat, id_field = NULL, sort_field = NULL) {
  
  # Convert to SpatialPointsDataFrame
  coordinates(data) <- c(long, lat)
  
  # If there is a sort field...
  if (!is.null(sort_field)) {
    if (!is.null(id_field)) {
      data <- data[order(data[[id_field]], data[[sort_field]]), ]
    } else {
      data <- data[order(data[[sort_field]]), ]
    }
  }
  
  # If there is only one path...
  if (is.null(id_field)) {
    
    lines <- SpatialLines(list(Lines(list(Line(data)), "id")))
    
    return(lines)
    
    # Now, if we have multiple lines...
  } else if (!is.null(id_field)) {  
    
    # Split into a list by ID field
    paths <- sp::split(data, data[[id_field]])
    
    sp_lines <- SpatialLines(list(Lines(list(Line(paths[[1]])), "line1")))
    
    # I like for loops, what can I say...
    for (p in 2:length(paths)) {
      # id <- paste0("line", as.character(p)) # original line
      lguy <- data.frame(paths[[p]][1]) # my addition
      id <- unique(lguy[,1]) # also mine
      l <- SpatialLines(list(Lines(list(Line(paths[[p]])), id)))
      sp_lines <- spRbind(sp_lines, l)
    }
    
    return(sp_lines)
  }
}

spatial_dcd$linkId <- as.character(spatial_dcd$linkId)

ptl <- points_to_line(data = spatial_dcd,
                      long = "lon",
                      lat = "lat",
                      id_field = "linkId",
                      sort_field = "sqno")

save(ptl, file="ptl.RDA")
