#!/bin/bash

# This script cleans up all the spin initial & spin finish that happened before the 
# automated file management was included in the run scripts
file_base=/projectnb/dietzelab/paleon/ED_runs/MIP2_Region # whatever you want the base output file path to be
setup_dir=${file_base}/0_setup/


# ---------------------
# Clean up Runs
# ---------------------
runs_dir=${file_base}/4_runs/phase2_runs.v1/ 
# spininit_dir=${file_base}/1_spin_initial/phase2_spininit.v1/ 
finalruns=2851

pushd $runs_dir
	runs_done=(lat*)
popd

# # ------- 
# # Skip files that were already done
# # ------- 
# files_skip=(lat35.25lon-79.75 lat35.25lon-79.75 lat35.25lon-79.75 lat35.25lon-94.75 lat35.25lon-99.75 lat37.75lon-77.25 lat37.75lon-82.25 lat47.25lon-95.25 lat47.75lon-67.25 lat47.75lon-82.25 lat47.75lon-92.25 lat47.75lon-97.25) # Right now these are from Betsy and Ann
# 
# for REMOVE in ${files_skip[@]}
# do 
# 	init_done=(${init_done[@]/$REMOVE/})
# done
# # ------- 


for SITE in ${runs_done[@]}
do
    spath=${runs_dir}${SITE}

	pushd ${spath}
		tar -jxvf analy.tar.bz2

		cp ${setup_dir}sub_reprocess_runs.sh .
		cp ${setup_dir}reprocess_runs.sh .
		sed -i "s,TEST,post_${SITE},g" sub_reprocess_runs.sh # change job name
		sed -i "s,/dummy/path,${spath},g" sub_reprocess_runs.sh # set the file path
		sed -i "s/SITE=.*/SITE=${SITE}/" reprocess_runs.sh
		sed -i "s/job_name=.*/job_name=extract_${SITE}/" reprocess_runs.sh
		sed -i "s,/dummy/path,${spath}/${SITE}_paleon,g" reprocess_runs.sh # set the file path
	
		qsub sub_post_process_runs_cleanup.sh
	popd
	fi
done
# ---------------------
