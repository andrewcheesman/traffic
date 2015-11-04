# Reads all recent observation caches and outputs some summary statistics and a graph
# Outputs focus on missing time periods
# Should be run and checked daily

library(ggplot2)
library(plyr)
library(gridExtra)

files <- data.frame(file=list.files("/home/awc/Traffic_1/dailies"))
diags <- data.frame()

pdf(file = "/home/awc/Traffic_1/diags/graphs.pdf")
for (i in 1:length(files[,1])) {
  load(paste0("/home/awc/Traffic_1/dailies/",files[i,1]))
  hldr <- data.frame(files[i,])
  hldr[1,2] <- as.character(as.POSIXlt(min(out2$rndtm, na.rm=T), origin=as.POSIXlt('1970-01-01'))) #start time
  hldr[1,3] <- as.character(as.POSIXlt(max(out2$rndtm, na.rm=T), origin=as.POSIXlt('1970-01-01'))) #end time
  hldr[1,4] <- length(out2[,1]) #number of total observations
  hldr[1,5] <- paste0(round(sum(is.na(out2$Speed))/length(out2[,1]), 2)*100,"%") #% of total observations null
  hldr[1,6] <- length(unique(out2$linkId)) #number of links observed
  hldr[1,7] <- length(unique(out2$rndtm)) #number of times observed
  out2[is.na(out2$Speed),4] <- 0
  aggs <- aggregate(Speed~rndtm, out2, mean)
  aggs$tick <- ifelse(aggs$Speed<(mean(aggs$Speed)-(2*sd(aggs$Speed))), 1, 0)
  hldr[1,8] <- paste0(round(sum(aggs$tick)/length(aggs$rndtm), 2)*100,"%") #percent of times that are all or mostly nulls
  diags <- rbind(diags, hldr)
  tp <- ggplot(aggs, aes(x=rndtm)) +
    geom_line(aes(y=Speed)) +
    ggtitle(files[i,1]) +
    theme_bw()
  plot(tp)
  rm(aggs, hldr, out2)
}
dev.off()

pdf(file = "/home/awc/Traffic_1/diags/table.pdf", width=10, height=4)
colnames(diags) <- c("file","tm_st","tm_nd","obs","pct_na","lnks","tms","tms_na")
grid.table(diags)
dev.off()
