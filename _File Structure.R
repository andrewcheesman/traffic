####################################
# File Descriptions and Scheduling #
####################################
# 
# Daily Jobs
# 1. CRON CURL (cron.txt): pulls data from NYCDOT and appends to data.txt
#    Runs every 10 minutes
# 2. 1_DFS_Gen_DailyObs.R: generates a daily obs_*.RDA file and deletes data.txt (was _format.R)
#    Runs every day a little after 4AM EST
# 3. 2_DIAGS.R: generates a daily graph and table for quick verification of CRON CURL job (was _diagnostics.R)
#    Runs every day a little after 4AM EST, and after the above
# 
# Weekly Jobs
# 1. 3_DFS_Gen_CompObs.R: generates a compiled observation repository (obs_com.RDA) (was compiler.R)
#    Runs every week on Mondays around 4AM EST, 15 minutes after the daily scripts
# 3. 4_MAP_Gen_SPLNDF.R: generates mappable spatialLinesDataFrames with speed data (at full-week, weekday, and weekend levels) and the ggplot feeder (speed_trailers) (was mapping.R)
#    Runs every week on Mondays around 4AM EST, 15 minutes after the daily scripts
#
# Ad Hoc Jobs
# 1. AH_MAP_Gen_SPLN.R: generates the basis for the spatialLinesDataFrame (ptl.RDA) (was spatial_setup.R); need only be run when this file needs to update
#    Not set to run automatically
# 2. Shiny Presentation:
#     a. global.R: loads spatialLinesDataFrame files for availability to Shiny
#     b. server.R: performs background computation for Shiny
#     c. ui.R: generates Shiny UI
#    Will run on accessing the traffic URL