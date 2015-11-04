# Setting the cron file that's used to pull the NYC speed data
# Also including a call that will format the archive daily at 0005 hr
# TODO: if runs successfully on its first day, then I'll also include a cron call that will delete the previous day's data file, to save space
cron <- "*/10 * * * * curl --silent http://207.251.86.229/nyc-links-cams/LinkSpeedQuery.txt >> /home/awc/Traffic_1/data.txt
05 04 * * * R --file=/home/awc/Traffic_1/_format.R"
write(cron, "cron.txt")

# 