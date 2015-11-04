# may eventually move with compilation/formatting/mapping script

library(ggplot2)
library(plyr)

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

