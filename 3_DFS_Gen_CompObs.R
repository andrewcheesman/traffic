# This script reads obs_* files, compiles them, and prepares them for mapping using leaflet
# Run whenever to pull together all observations files into one
# Later should be scheduled weekly or every few days, depending on data sizes and uptime of the cacher

files <- data.frame(file=list.files("/home/awc/Traffic_1/dailies"))
comp <- data.frame()

for (i in 1:length(files[,1])) {
  load(paste0("/home/awc/Traffic_1/dailies/",files[i,1]))
  # out2$pr=i
  out3 <- out2[is.na(out2$Speed)==F,]
  comp <- rbind(comp, out3)
  rm(out2,out3)
}
comp2 <- unique(comp)
assign("data", comp2)
rm(comp, files, i, comp2)

save(data, file = "/home/awc/Traffic_1/obs_com.RDA")

rm(data)