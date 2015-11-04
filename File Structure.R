####################################
# File Descriptions and Scheduling #
####################################
# 
# Daily Jobs
# 1. CRON CURL (cron.txt): pulls data from NYCDOT every 10 minutes; appends to data.txt
# 2. _format.R: generates a daily obs_*.RDA file and deletes data.txt
# 3. _diags.R: generates a daily graph and table for quick verification of CRON CURL job
# 
# Weekly Jobs
# 1. compiler.R: generates a compiled observation repository (obs_com.RDA)
# 2. _spatial_setup.R: generates the basis for the spatialLinesDataFrame (ptl.RDA)
# 3. mapping.R: generates mappable spatialLinesDataFrames (at full-week, weekday, and weekend levels) and the ggplot feeder (speed_trailers)
# 4. graphing.R: generates avg_speed.RDA from speed_trailers # TODO: remove this step; generate avg_speed in mapping.R
# 
# Ad Hoc Jobs
# 1. Shiny Presentation:
#     a. global.R: loads spatialLinesDataFrame files for availability to Shiny
#     b. server.R: performs background computation for Shiny
#     c. ui.R: generates Shiny UI