# Script to start runs with default check & restart before the Wallclock runs out

# Pseudocode to figure out the necessary workflow
# Code for my different ways of noting things below
# 1. == ordered workflow
# $$ == actual code/commands to use (pirated from existing scripts)
# a. == conceptual options for executing the flow
# -- == question I don't know the answer to
# ** == action to do that doesn't have a specific command at this time

### MODIFY START_RUNS.SH to spawn restart loop for each site
# 1. Use start_runs.sh to set up ED2IN & copy file
#    -- Note: Do NOT do the qsub
#    ** FIRST TIME THROUGH ONLY
# 2. Shift to the new folder and spawn a cycle of checking restart in that location
#    -- modification of start_runs.sh
#    $$ qsub spawn_startloops.sh

### SPAWN_STARTLOOPS.SH
# 1. Identify the last year in the folder; call run.start
#      $$ startday=`ls -l -rt ${path}/histo| tail -1 | rev | cut -c15-16 | rev`
#      $$ startmonth=`ls -l -rt ${path}/histo| tail -1 | rev | cut -c18-19 | rev`
#      $$ startyear=`ls -l -rt ${path}/histo| tail -1 | rev | cut -c21-24 | rev`
# 2. Make sure the start years in ED2IN are equal to the start time
#      $$ sed -i "s/IYEARA   =.*/IYEARA   = ${startyear}  /" ED2IN 
#      $$ sed -i "s/IDATEA   =.*/IDATEA   = ${startday}   /" ED2IN 
#      $$ sed -i "s/IMONTHA  =.*/IMONTHA  = ${startmonth} /" ED2IN 
#      $$ sed -i "s/IYEARH   =.*/IYEARH   = ${startyear}  /" ED2IN 
#      $$ sed -i "s/IDATEH   =.*/IDATEH   = ${startday}   /" ED2IN 
#      $$ sed -i "s/IMONTHH  =.*/IMONTHH  = ${startmonth} /" ED2IN 
# 3. Start simulations with time deliberately well under the max walltime (to account 
#    for queue delays)
#      $$ qsub paleon_ed2_smp_geo.sh
#      -- can we extract the job ID so we can keep tracking it?
# 4. Wait until the runs have timed out and/or the job is no longer running
#      a. wait [time_long] then do restart check
#      b. wait [time_short] then check & see if job is still running using qstat 
# 5. After job has stopped, extract the last year (run.end) & check to see if we need 
#    to restart the runs:
#      a. if run.end == sim.finish (3010), We're done, everything happy
#          ** Send me an email saying DONE!!
#     b. if run.end == run.start, we didn't make any progress and we need to see what's going on
#          ** Runs a "restart_crash" script
#          a. start a script that reduces the time step by 60 seconds for 2 months, then bumps it 
#             back up if things run
#          b. send me an email saying something's wrong so I manually restart it
#     c. if run.end < sim.finish & run.end > run.start, everything's fine & we just need to restart
#          $$ qsub spawn_startloops.sh
#          -- can I call a file within itself?
