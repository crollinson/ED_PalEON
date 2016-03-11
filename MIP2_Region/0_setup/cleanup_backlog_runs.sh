#!/bin/bash

# This script cleans up all the spin initial & spin finish that happened before the 
# automated file management was included in the run scripts
file_base=/projectnb/dietzelab/paleon/ED_runs/MIP2_Region # whatever you want the base output file path to be
setup_dir=${file_base}/0_setup/


# ---------------------
# Clean up Runs
# ---------------------
runs_dir=${file_base}/4_runs/phase2_runs.v1/ 
spininit_dir=${file_base}/1_spin_initial/phase2_spininit.v1/ 
finalruns=2851

pushd $runs_dir
	runs_done=(lat*)
popd

for SITE in ${runs_done[@]}
do
	#get dates of last histo file
    spath=${runs_dir}${SITE}
    lastyear=`ls -l -rt ${spath}/histo| tail -1 | rev | cut -c21-24 | rev`

	# If the last year isn't the last year of the spin finish, don't do it for now
	if [[(("${lastyear}" < "${finalinit}"))]]
	then
		echo "  Site not done: $SITE"
		break # if it's not done, skip to the next item
	else
		pushd ${spath}
			cp ${setup_dir}sub_post_process_runs_cleanup.sh .
			cp ${setup_dir}post_process_runs_cleanup.sh .
	    	sed -i "s,TEST,post_${SITE},g" sub_post_process_runs_cleanup.sh # change job name
	    	sed -i "s,/dummy/path,${spath},g" sub_post_process_runs_cleanup.sh # set the file path
			sed -i "s/SITE=.*/SITE=${SITE}/" post_process_runs_cleanup.sh
			sed -i "s/job_name=.*/job_name=extract_${SITE}/" post_process_runs_cleanup.sh
			sed -i "s,/dummy/path,${spath}/${SITE}_paleon,g" post_process_runs_cleanup.sh # set the file path

			cp ${setup_dir}submit_ED_extraction.sh .
			cp ${setup_dir}extract_output_paleon.R .
		    sed -i "s,TEST,extract_${SITE},g" submit_ED_extraction.sh # change job name
		    sed -i "s,/dummy/path,${spath},g" submit_ED_extraction.sh # set the file path
			sed -i "s/site=.*/site='${SITE}'/" extract_output_paleon.R
		    sed -i "s,/dummy/path,${spath},g" extract_output_paleon.R # set the file path
	    
			cp ${setup_dir}cleanup_runs.sh .
			cp ${setup_dir}sub_cleanup_runs.sh .
		    sed -i "s,/DUMMY/PATH,${spath}/,g" cleanup_runs.sh # set the file path
			sed -i "s/SITE=.*/SITE=${SITE}/" cleanup_runs.sh
		    sed -i "s/lastyear=.*/lastyear=${finalruns}/" cleanup_runs.sh
		    sed -i "s,/dummy/path,${spath},g" sub_cleanup_runs.sh # set the file path
		    sed -i "s,TEST,clean_${SITE}_runs,g" sub_cleanup_runs.sh # change job name
 		
	 		qsub sub_post_process_runs_cleanup.sh
	 	popd
	fi
done
# ---------------------
