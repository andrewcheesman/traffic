# This script generates spatialLinesDataFrames (joining speed and geo data) as layers for use in mapping
# Uses different levels of aggregation
# Saves files, all identified by time, to separate subfolder; each subfolder contains files for that level of agg
# This script runs one for() loop for each agg level

# Addition 10/29/15 - also now compiles a single summary df for use in graphing
# And generates a single vector to set a unified coloring scheme

# Useful description of how to reference SP lists
# http://r.789695.n4.nabble.com/Retrieving-Vertices-Coordinates-from-SpatialPolygons-td881739.html

###########################################################################################
# Everything here required for all four loops
###########################################################################################

library(sp)
library(plyr)

load("/home/awc/Traffic_1/ptl.RDA")
load("/home/awc/Traffic_1/obs_com.RDA")

# Take unique ids from existing SpatialLines object (ptl)

ids <- data.frame()
for (j in (1:length(ptl))) {
  id <- data.frame(ptl@lines[[j]]@ID)
  ids <- rbind(ids, id)
}
colnames(ids)[1] <- "linkId"

rm(id, j)

###########################################################################################
# Everything above this line is required for all four loops
###########################################################################################

# Generate most granular agg files - one per time observation; saved to sldf_straight
# Files named for the unix time of their observation
# Files not aggregated at all - this is raw

# First figure out which times have enough observations to be useful to map

times <- aggregate(Speed~rndtm, data=data, length)
timesub <- times[times$Speed > 120,]
rm(times)

for (i in 1:length(timesub[,1])) {
  
  tm_sb <- data[data$rndtm==paste0(timesub[i,1]),]
  tm_sb_tn <- data.frame(tm_sb[,c(2,4)])
  colnames(tm_sb_tn) <- c("linkId","speed")
  
  # There are some cases where linkId*time pairs have duplicate speed observations
  # Caused by inaccuracy in the camera sampling, I believe
  # The below aggregates for time to come to a single observation for each linkId*time pair
  
  speed_full <- join(ids, tm_sb_tn)
  speed_full[is.na(speed_full$speed),2] <- 0
  speed_full_unq <- aggregate(speed~linkId, data=speed_full, mean)
  speed_full_short <- data.frame(speed_full_unq[,c(-1)])
  row.names(speed_full_short) <- speed_full_unq$linkId
  splndf <- SpatialLinesDataFrame(ptl, data = speed_full_short, match.ID = T)
  
  fnm <- paste0("/home/awc/Traffic_1/sldf_straight/splndf_",as.numeric(timesub[i,1]),".RDA",sep="")
  save(splndf, file=fnm)
  
  #build a thing that'll cache a city-wide speed average by time; write to disk
  
  colnames(speed_full_short) <- "speed"
  speed_full_short[speed_full_short$speed==0,1] <- NA
  speed_avg <- data.frame(time = as.numeric(timesub[i,1]),
                          avg_spd = mean(speed_full_short[,1], na.rm = T))
  
  if(exists("speed_trailer_straight")==F) {
    speed_trailer_straight <- speed_avg } else {
      speed_trailer_straight <- rbind(speed_trailer_straight, speed_avg)
      }
  
  rm(speed_full, speed_full_short, speed_avg, tm_sb, tm_sb_tn, speed_full_unq)
  
}

spd_trl_fnm <- paste0("/home/awc/Traffic_1/sldf_straight/speed_trailer_straight.RDA",sep="")
save(speed_trailer_straight, file=spd_trl_fnm)

rm(timesub, i, splndf, fnm, spd_trl_fnm, speed_trailer_straight)

###########################################################################################
# Generate agg files for all days of week
# First generate an aggregated version of 'data' object, for linkId*time across days

data2 <- data
data2$time <- as.numeric(strftime(data2$rndtm, format = "%H%M"))
data_agg_full <- aggregate(Speed~linkId+time, data=data2, mean)

times2 <- aggregate(Speed~time, data=data2, length)
timesub2 <- times2[times2$Speed > 120,]
rm(times2, data2)

for (k in 1:length(timesub2[,1])) {
  
  tm_sb2 <- data_agg_full[data_agg_full$time==paste0(timesub2[k,1]),]
  tm_sb_tn2 <- data.frame(tm_sb2[,c(1,3)])
  colnames(tm_sb_tn2) <- c("linkId","speed")
  
  speed_full2 <- join(ids, tm_sb_tn2)
  speed_full2[is.na(speed_full2$speed),2] <- 0
  speed_full_unq2 <- aggregate(speed~linkId, data=speed_full2, mean)
  speed_full_short2 <- data.frame(speed_full_unq2[,c(-1)])
  row.names(speed_full_short2) <- speed_full_unq2$linkId
  splndf <- SpatialLinesDataFrame(ptl, data = speed_full_short2, match.ID = T)
  
  fnm2 <- paste0("/home/awc/Traffic_1/sldf_agg_full/splndf_",as.numeric(timesub2[k,1]),".RDA",sep="")
  save(splndf, file=fnm2)

  # outputting thing to save speed over time
  
  colnames(speed_full_short2) <- "speed"
  speed_full_short2[speed_full_short2$speed==0,1] <- NA
  speed_avg2 <- data.frame(time = as.numeric(timesub2[k,1]),
                           avg_spd = mean(speed_full_short2[,1], na.rm = T))
  
  if(exists("speed_trailer_full")==F) {
    speed_trailer_full <- speed_avg2 } else {
      speed_trailer_full <- rbind(speed_trailer_full, speed_avg2)
    }
  
  rm(speed_full2, speed_avg2, speed_full_short2, tm_sb2, tm_sb_tn2, speed_full_unq2, fnm2)
  
}

spd_trl_fnm2 <- paste0("/home/awc/Traffic_1/speed_trailer_full.RDA",sep="")
save(speed_trailer_full, file=spd_trl_fnm2)

rm(data_agg_full, timesub2, k, speed_trailer_full, splndf, spd_trl_fnm2)

###########################################################################################
# Generate agg files for weekdays (M-F)
# First remove all observations that occurred on weekends
# Also creates a flag that can be used below, for weekends

data3 <- data
data3$time <- as.numeric(strftime(data3$rndtm, format = "%H%M"))
data3$dow <- as.numeric(strftime(data3$rndtm, format = "%w"))+1
data3$wkdy_flg <- ifelse(data3$dow>=2 & data3$dow<=6, 1, 0)
data_agg_wkdy <- aggregate(Speed~linkId+time, data=data3[data3$wkdy_flg==1,], mean)

times3 <- aggregate(Speed~time, data=data_agg_wkdy, length)
timesub3 <- times3[times3$Speed > 120,]
rm(times3, data3)

for (l in 1:length(timesub3[,1])) {
  
  tm_sb3 <- data_agg_wkdy[data_agg_wkdy$time==paste0(timesub3[l,1]),]
  tm_sb_tn3 <- data.frame(tm_sb3[,c(1,3)])
  colnames(tm_sb_tn3) <- c("linkId","speed")
  
  speed_full3 <- join(ids, tm_sb_tn3)
  speed_full3[is.na(speed_full3$speed),2] <- 0
  speed_full_unq3 <- aggregate(speed~linkId, data=speed_full3, mean)
  speed_full_short3 <- data.frame(speed_full_unq3[,c(-1)])
  row.names(speed_full_short3) <- speed_full_unq3$linkId
  splndf <- SpatialLinesDataFrame(ptl, data = speed_full_short3, match.ID = T)
  
  fnm3 <- paste0("/home/awc/Traffic_1/sldf_agg_wkdy/splndf_",as.numeric(timesub3[l,1]),".RDA",sep="")
  save(splndf, file=fnm3)
  
  # outputting thing to save speed over time
  
  colnames(speed_full_short3) <- "speed"
  speed_full_short3[speed_full_short3$speed==0,1] <- NA
  speed_avg3 <- data.frame(time = as.numeric(timesub3[l,1]),
                           avg_spd = mean(speed_full_short3[,1], na.rm = T))
  
  if(exists("speed_trailer_wkdy")==F) {
    speed_trailer_wkdy <- speed_avg3 } else {
      speed_trailer_wkdy <- rbind(speed_trailer_wkdy, speed_avg3)
    }
  
  rm(speed_full3, speed_full_short3, speed_avg3, tm_sb3, tm_sb_tn3, speed_full_unq3, fnm3)
  
}

spd_trl_fnm3 <- paste0("/home/awc/Traffic_1/speed_trailer_wkdy.RDA",sep="")
save(speed_trailer_wkdy, file=spd_trl_fnm3)

rm(data_agg_wkdy, speed_trailer_wkdy, timesub3, l, splndf, spd_trl_fnm3)

###########################################################################################
# Generate agg files for weekends (S+S)
# Uses same method as above, simply reversing the record ID logic (yes/no weekday)

data3 <- data
data3$time <- as.numeric(strftime(data3$rndtm, format = "%H%M"))
data3$dow <- as.numeric(strftime(data3$rndtm, format = "%w"))+1
data3$wkdy_flg <- ifelse(data3$dow>=2 & data3$dow<=6, 0, 1)
data_agg_wkdy <- aggregate(Speed~linkId+time, data=data3[data3$wkdy_flg==1,], mean)

times3 <- aggregate(Speed~time, data=data_agg_wkdy, length)
timesub3 <- times3[times3$Speed > 120,]
rm(times3, data3)

for (m in 1:length(timesub3[,1])) {
  
  tm_sb3 <- data_agg_wkdy[data_agg_wkdy$time==paste0(timesub3[m,1]),]
  tm_sb_tn3 <- data.frame(tm_sb3[,c(1,3)])
  colnames(tm_sb_tn3) <- c("linkId","speed")
  
  speed_full3 <- join(ids, tm_sb_tn3)
  speed_full3[is.na(speed_full3$speed),2] <- 0
  speed_full_unq3 <- aggregate(speed~linkId, data=speed_full3, mean)
  speed_full_short3 <- data.frame(speed_full_unq3[,c(-1)])
  row.names(speed_full_short3) <- speed_full_unq3$linkId
  splndf <- SpatialLinesDataFrame(ptl, data = speed_full_short3, match.ID = T)
  
  fnm3 <- paste0("/home/awc/Traffic_1/sldf_agg_wknd/splndf_",as.numeric(timesub3[m,1]),".RDA",sep="")
  save(splndf, file=fnm3)

  # outputting thing to save speed over time
  
  colnames(speed_full_short3) <- "speed"
  speed_full_short3[speed_full_short3$speed==0,1] <- NA
  speed_avg3 <- data.frame(time = as.numeric(timesub3[m,1]),
                           avg_spd = mean(speed_full_short3[,1], na.rm = T))
  
  if(exists("speed_trailer_wknd")==F) {
    speed_trailer_wknd <- speed_avg3 } else {
      speed_trailer_wknd <- rbind(speed_trailer_wknd, speed_avg3)
    }
  
  rm(speed_full3, speed_full_short3, speed_avg3, tm_sb3, tm_sb_tn3, speed_full_unq3, fnm3)
  
}

spd_trl_fnm3 <- paste0("/home/awc/Traffic_1/speed_trailer_wknd.RDA",sep="")
save(speed_trailer_wknd, file=spd_trl_fnm3)

rm(list=ls())

##################################################
# Imported from old file 'graphing.R'
# Prepares speed rollups for graphing in ggplot

load("/home/awc/Traffic_1/speed_trailer_full.RDA")
load("/home/awc/Traffic_1/speed_trailer_wkdy.RDA")
load("/home/awc/Traffic_1/speed_trailer_wknd.RDA")

speed_trailer_full$id <- "All"
speed_trailer_wkdy$id <- "Wkdys"
speed_trailer_wknd$id <- "Wknds"

avg_speed <- rbind(speed_trailer_full, 
                   speed_trailer_wkdy,
                   speed_trailer_wknd)

rm(speed_trailer_full,
   speed_trailer_wkdy,
   speed_trailer_wknd)

colnames(avg_speed)[3] <- "Period"

save(avg_speed, file="/home/awc/Traffic_1/avg_speeds.RDA")
