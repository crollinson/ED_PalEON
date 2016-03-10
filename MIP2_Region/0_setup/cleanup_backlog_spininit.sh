#!/bin/bash

# This script cleans up all the spin initial & spin finish that happened before the 
# automated file management was included in the run scripts
file_base=/projectnb/dietzelab/paleon/ED_runs/MIP2_Region # whatever you want the base output file path to be
setup_dir=${file_base}/0_setup/


# ---------------------
# Clean up Spin Initial
# ---------------------
spininit_dir=${file_base}/1_spin_initial/phase2_spininitial.v1/ 
finalinit=2851

pushd $spininit_dir
	init_done=(lat*)
popd

for SITE in ${init_done[@]}
do
	echo $SITE

	#get dates of last histo file
    spath=${spininit_dir}${SITE}
    lastday=`ls -l -rt ${spath}/histo| tail -1 | rev | cut -c15-16 | rev`
    lastmonth=`ls -l -rt ${spath}/histo| tail -1 | rev | cut -c18-19 | rev`
    lastyear=`ls -l -rt ${spath}/histo| tail -1 | rev | cut -c21-24 | rev`

	# If the last year isn't the last year of the spin finish, don't do it for now
	if [[(("${lastyear}" < "${finalinit}"))]]
	then
		echo "  Site not done: $SITE"
		break # if it's not done, skip to the next item
	else
		pushd ${spath}
			cp ${setup_dir}sub_post_process_spininit_cleanup.sh .
			cp ${setup_dir}post_process_spininit_cleanup.sh .
	    	sed -i "s,TEST,post_${SITE},g" sub_post_process_spininit_cleanup.sh # change job name
	    	sed -i "s,/dummy/path,${spath},g" sub_post_process_spininit_cleanup.sh # set the file path
			sed -i "s/SITE=.*/SITE=${SITE}/" post_process_spininit_cleanup.sh 		
			sed -i "s/job_name=.*/job_name=extract_${SITE}/" post_process_spininit_cleanup.sh 		

			cp ${setup_dir}submit_ED_extraction.sh .
			cp ${setup_dir}extract_output_paleon.R .
		    sed -i "s,TEST,extract_${SITE},g" submit_ED_extraction.sh # change job name
		    sed -i "s,/dummy/path,${spath},g" submit_ED_extraction.sh # set the file path
			sed -i "s/site=.*/site='${SITE}'/" extract_output_paleon.R
		    sed -i "s,/dummy/path,${spath},g" extract_output_paleon.R # set the file path
	    
			cp ${setup_dir}cleanup_spininit.sh .
			cp ${setup_dir}sub_cleanup_spininit.sh .
		    sed -i "s,/DUMMY/PATH,${spath}/,g" cleanup_spininit.sh # set the file path
			sed -i "s/SITE=.*/SITE=${SITE}/" cleanup_spininit.sh 		
		    sed -i "s/spin_last=.*/spin_last=${finalinit}/" cleanup_spininit.sh 		
		    sed -i "s,/dummy/path,${spath},g" sub_cleanup_spininit.sh # set the file path
		    sed -i "s,TEST,clean_${SITE}_spininit,g" sub_cleanup_spininit.sh # change job name
 		
	 		qsub sub_post_process_spininit_cleanup.sh
	 	popd
	fi		
done
# ---------------------
