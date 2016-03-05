# Script to get past crashes because of integration errors
#  Sometimes the model hits an unstable state and can't solve
#  To solve this problem, we need to manually adjust the model timestep 
#  for a month or two and then restart it



USER=crolli # or whoever is in charge of this site
SITE=latXXXlon-XXX # Site can be indexed off some file name
finalyear=3010
outdir=/projectnb/dietzelab/paleon/ED_runs/MIP2_Region/4_runs/phase2_runs.v1/
site_path=${outdir}${SITE}/

months=(01 02 03 04 05 06 07 08 09 10 11 12 01 02)

# 1. Figuring out where we're restarting from
startday=`ls -l -rt ${site_path}/histo| tail -1 | rev | cut -c15-16 | rev`
startmonth=`ls -l -rt ${site_path}/histo| tail -1 | rev | cut -c18-19 | rev`
startyear=`ls -l -rt ${site_path}/histo| tail -1 | rev | cut -c21-24 | rev`

# 2.a. Editing the ED2IN to restart
sed -i "s/IYEARA   =.*/IYEARA   = ${startyear}   ! Year/" ED2IN 
sed -i "s/IDATEA   =.*/IDATEA   = ${startday}     ! Day/" ED2IN 
sed -i "s/IMONTHA  =.*/IMONTHA  = ${startmonth}     ! Month/" ED2IN 
sed -i "s/IYEARH   =.*/IYEARH   = ${startyear}   ! Year/" ED2IN 
sed -i "s/IDATEH   =.*/IDATEH   = ${startday}     ! Day/" ED2IN 
sed -i "s/IMONTHH  =.*/IMONTHH  = ${startmonth}     ! Month/" ED2IN 
sed -i 's/IED_INIT_MODE   =.*/IED_INIT_MODE   = 5/' ED2IN
sed -i "s/RUNTYPE  =.*/RUNTYPE  = 'HISTORY'/" ED2IN

# 2.b. Temporarily adjust the integration time point & end dates/time
# New timestep = old - 120 (2 minutes finer)
# Temp End = 2 months in future
n=(`echo ${months[@]} | tr -s " " "\n" | grep -n $startmonth | cut -d":" -f 1`)
n=$(($n+1)) # ends up giving us the number for the second in line

finalmonth=${months[$n]}

# If 2 months into future puts us in another year, we need to adjust that in the ED2IN
if [[(("${finalmonth}" -lt "03"))]]
then
	finalyear=$(($startyear+1))
else
	finalyear=$startyear
fi

sed -i "s/IMONTHZ  =.*/IMONTHZ  = ${finalmonth}/" ED2IN 
sed -i "s/IYEARZ   =.*/IMONTHZ  = ${finalyear}/" ED2IN 
sed -i "s/DTLSM  =.*/DTLSM  = 320/" ED2IN 
sed -i "s/RADFRQ  =.*/RADFRQ  = 320/" ED2IN 

# 3. Submit the job!
qsub paleon_ed2_smp_geo.sh	

# 4. Check for it to get through the finish point
# 4. Enter a loop checking the status
while true
do
    sleep 300 #only run every 5 minutes
	chmod -R a+rwx site_path # First make sure everyone can read/write/use ALL of these files!

    runstat=$(qstat -j ${SITE$} | wc -l)

    #if run has stopped go to step 5
    if [[ "${runstat}" -eq 0 ]] # If run has stopped, go to step 5
    then
		lastday=`ls -l -rt ${site_path}/histo| tail -1 | rev | cut -c15-16 | rev`
	    lastmonth=`ls -l -rt ${site_path}/histo| tail -1 | rev | cut -c18-19 | rev`
	    lastyear=`ls -l -rt ${site_path}/histo| tail -1 | rev | cut -c21-24 | rev`

	    if [[(("lastmonth" -eq "finalmonth"))]] # NEED To match year & Month
    	then # # 5. If we succeeded, put the end point back to where it should be
    		sed -i "s/IMONTHZ  =.*/IMONTHZ  = 01/" ED2IN 
			sed -i "s/IYEARZ   =.*/IMONTHZ  = 3011/" ED2IN 
			sed -i "s/DTLSM  =.*/DTLSM  = 540/" ED2IN 
			sed -i "s/RADFRQ  =.*/RADFRQ  = 540/" ED2IN 

            qsub sub_spawn_restarts.sh # Go back to checking this as normal
    	else
    		if [[(("${lastmonth}" -eq "${startmonth}"))]] # We're not making progress!
	    	then # case b: we're crashing, don't keep trying without changing something (send email)
	    		EMAIL_TXT=$(echo 'Houston we have a problem! site' ${SITE} 'failed.  NEED TO LOOK AT IT!'
	    		echo 'Last Year/Mo/day :' $lastyear $lastmonth $lastday)
	    		
	    		EMAIL_SUB=$(echo 'ED Run Fail: ' ${SITE}) 
	    		
	    		mail -s $EMAIL_SUB crollinson@gmail.com <<< $EMAIL_TEXT
	    		break
	    	fi
    	fi
    fi # No else because we just keep going until we're not running anymore
    done
done

