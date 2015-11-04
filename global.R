
library(sp)

# Loading datasets
# Should be available to all sessions

load("/srv/shiny-server/traffic/skeleton.RDA")

# Weekdays
for (j in 1:length(skeleton[,1])) {
  load(paste("/srv/shiny-server/traffic/sldf_agg_wkdy/", as.character(skeleton[j,1]), sep=""))
  assign(paste("wkdy_",j, sep=""), splndf)
}

# Weekends
for (j in 1:length(skeleton[,1])) {
  load(paste("/srv/shiny-server/traffic/sldf_agg_wknd/", as.character(skeleton[j,1]), sep=""))
  assign(paste("wknd_",j, sep=""), splndf)
}

# All
for (j in 1:length(skeleton[,1])) {
  load(paste("/srv/shiny-server/traffic/sldf_agg_full/", as.character(skeleton[j,1]), sep=""))
  assign(paste("full_",j, sep=""), splndf)
}
