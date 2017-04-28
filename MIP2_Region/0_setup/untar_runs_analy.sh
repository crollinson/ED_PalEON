#!/bin/bash

# This script cleans up all the spin initial & spin finish that happened before the 
# automated file management was included in the run scripts
file_base=/home/crollinson/ED_PalEON/MIP2_Region # whatever you want the base output file path to be
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

# ------- 
# Skip files that don't need to be re-processed
# ------- 
files_skip=(lat45.25lon-69.75)

for REMOVE in ${files_skip[@]}
do 
	runs_done=(${runs_done[@]/$REMOVE/})
done
# ------- 


for SITE in ${runs_done[@]}
do
    spath=${runs_dir}${SITE}

	pushd ${spath}
		rm -rf analy
		tar -jxvf analy.tar.bz2
	popd
done
# ---------------------
