####################################
# File Descriptions and Scheduling #
####################################
# 
# Daily Jobs
# 1. CRON CURL (cron.txt): pulls data from NYCDOT every 10 minutes; appends to data.txt
# 2. 1_DFS_Gen_DailyObs.R: generates a daily obs_*.RDA file and deletes data.txt (was _format.R)
# 3. 2_DIAGS.R: generates a daily graph and table for quick verification of CRON CURL job (was _diagnostics.R)
# 
# Weekly Jobs
# 1. 3_DFS_Gen_CompObs.R: generates a compiled observation repository (obs_com.RDA) (was compiler.R)
# 3. 4_MAP_Gen_SPLNDF.R: generates mappable spatialLinesDataFrames with speed data (at full-week, weekday, and weekend levels) and the ggplot feeder (speed_trailers) (was mapping.R)
# 
# Ad Hoc Jobs
# 1. AH_MAP_Gen_SPLN.R: generates the basis for the spatialLinesDataFrame (ptl.RDA) (was spatial_setup.R); need only be run when this file needs to update
# 2. Shiny Presentation:
#     a. global.R: loads spatialLinesDataFrame files for availability to Shiny
#     b. server.R: performs background computation for Shiny
#     c. ui.R: generates Shiny UI