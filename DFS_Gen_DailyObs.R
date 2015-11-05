# This script performs basic formatting and subsetting operations on data.txt
# It then saves its results to disk in a better-structured running file, formatted as .RDA to save space
# Will remove all but time and speed-relative information; spatial info is contained in spatial.txt
# data.txt should never contain more than one day's observations

# Effectively, creates a single RDA file that is a daily log of all data gathered from the NYC site

library(plyr)

data <- read.delim("/home/awc/Traffic_1/data.txt")

# Reformatting date field
data$obsTime <- strptime(as.character(data$DataAsOf), format = "%m/%d/%Y %H:%M:%S")

# Subsetting for valid dates and nulls
d.1 <- data[data$obsTime>="2015-10-06",]
d.2 <- d.1[is.na(d.1$obsTime)==F,]

# Subsetting fields
observations <- d.2[,c(1,6,2,3,14)]
observations[,c(3,4)] <- apply(observations[,c(3,4)], 2, function(x) as.numeric(as.character(x)))
observations$rndtm <-  as.POSIXlt(round(as.double(observations$obsTime)/(10*60))*(10*60),origin=(as.POSIXlt('1970-01-01')))

# Creating observation time framework - one record per ten minutes per linkid
# Converts all times to increments of 10 minutes
time_stem <- data.frame(const=1, times=seq(min(observations$rndtm), max(observations$rndtm), by = 600))
link_stem <- data.frame(const=1, unique(observations$linkId))

comp_stem_1 <- merge(time_stem, link_stem, by="const")
comp_stem <- comp_stem_1[,2:3]
colnames(comp_stem) <- c("rndtm","linkId")

rm(d.1, d.2, data, comp_stem_1, link_stem, time_stem)

out1 <- join(comp_stem, observations, type="left")
out2 <- out1[,c(-6)]

# Treating outliers in Speed and Traveltime
# hist(out2$Speed, breaks=200) -> outlier cutoff based on eyeballing = 90
# hist((out2$TravelTime/60), breaks=200) -> outlier cutoff based on eyeballing = 30 min (1800s)
out2$Speed <- ifelse(out2$Speed>90, NA, out2$Speed)
out2$TravelTime <- ifelse(out2$TravelTime>1800, NA, out2$TravelTime)

# Removing cameras whose time settings have failed to update
# (In early runs, was seeing some cameras that continually gave old "DataAsOf" readings)
# Removing these by taking only records with time as ~24hrs before runtime
out2 <- subset(out2, out2$rndtm >= as.POSIXct(paste(Sys.Date()-2,"23:55:00" )))

# Naming crap
filename <- gsub(paste0("/home/awc/Traffic_1/dailies/obs_", Sys.Date()-1, ".RDA"),pattern = "-", replacement = "")
save(out2, file=filename)

# Checks for successful write of out2 (observation daily log)
# Removes previously-cached data.txt if so
# A new iteration of data.txt will be created at the next curl run

if(file.exists(
  gsub(paste0("/home/awc/Traffic_1/dailies/obs_", Sys.Date()-1, ".RDA"),pattern = "-", replacement = ""))==T) {
  load(gsub(paste0("/home/awc/Traffic_1/dailies/obs_", Sys.Date()-1, ".RDA"),pattern = "-", replacement = ""))
  file.remove("/home/awc/Traffic_1/data.txt")}
