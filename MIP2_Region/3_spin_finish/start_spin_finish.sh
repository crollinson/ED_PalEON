#!bin/bash
# This file runs the transient runs post SAS steady-state calculations to get to true(er)
# steady-state conditions
# Christy Rollinson, crollinson@gmail.com
# January, 2016

# Order of operations for starting the spin finish after having run the SAS script
# 1. get list of sites that have an SAS init folder and use that to figure out what we're
#    need to run a spin finish (transient runs) on 
# 2. copy the basic files for an ED run (ED2IN, link to executable, .xml file) to the new 
#    folder
# 3. Change file paths, init mode, & turn on disturbance in ED2IN

# Things to change from the spin initial
#   run title = Spin Finish (Post-SAS) (NL%EXPNME)
#   init mode = 3 (uses .css & .pss files; ignoring the descriptions as they don't line up
#               with my understanding of the different innitialization methods)
#   turn on disturbance (fire, treefall)
#   all fille paths from initial spin to final spin

# Load the necessary hdf5 library
# module load hdf5/1.6.10

# Define constants & file paths for the scripts
# Note: do not need to re
file_base=/home/crollinson/ED_PalEON/MIP2_Region # whatever you want the base output file path to be

ed_exec=/home/crollinson/ED2/ED/build/ed_2.1-opt # Location of the ED Executable
init_dir=${file_base}/1_spin_initial/phase2_spininit.v1/ # Directory of initial spin files
SAS_dir=${file_base}/2_SAS/SAS_init_files.v1/ # Directory of SAS initialization files
finish_dir=${file_base}/3_spin_finish/phase2_spinfinish.v1/ # Where the transient runs will go
setup_dir=${file_base}/0_setup/

finalyear=2351 # The year on which the models should top on Jan 1
finalfull=2350 # The last year we actually care about (probably the year before finalyear)
finalinit=2851

n=3

# Making the file directory if it doesn't already exist
mkdir -p $finish_dir

# Get the list of what grid cells have already finished spinups
pushd $finish_dir
	file_done=(lat*)
popd

# Get the list of what grid cells have SAS solutions
pushd $SAS_dir
	cells=(lat*)
popd


# This will probably be slow later on, but will probably be the best way to make sure we're
# not skipping any sites
# NOTE: NEED TO COMMENT THIS PART OUT FIRST TIME THROUGH 
#       because it doesn't like no matches in file_done
for REMOVE in ${file_done[@]}
do 
	cells=(${cells[@]/$REMOVE/})
done


for ((FILE=0; FILE<$n; FILE++)) # This is a way of doing it so that we don't have to modify N
do
	# Site Name and Lat/Lon
	SITE=${cells[FILE]}
	echo $SITE
	
	# Make a new folder for this site
	file_path=${finish_dir}/${SITE}/
	mkdir -p ${file_path} 

	pushd ${file_path}
		# Creating the default file structure and copying over the base files to be modified
		mkdir -p histo analy
		ln -s $ed_exec
		cp ${init_dir}${SITE}/ED2IN .
		cp ${init_dir}${SITE}/PalEON_Phase2.v1.xml .
		cp ${init_dir}${SITE}/paleon_ed2_smp_geo.sh .

		# ED2IN Changes	    
	    sed -i "s,$init_dir,$finish_dir,g" ED2IN #change the baseline file path everywhere
        sed -i "s/NL%EXPNME =.*/NL%EXPNME = 'PalEON Spin Finish'/" ED2IN # change the experiment name
		sed -i "s/NL%RUNTYPE  = .*/NL%RUNTYPE  = 'INITIAL'/" ED2IN # change from bare ground to .css/.pss run
        sed -i "s/NL%IYEARA   = .*/NL%IYEARA   = 1850/" ED2IN # Set first year
        sed -i "s/NL%IMONTHA  = .*/NL%IMONTHA  = 06/" ED2IN # Set first month
        sed -i "s/NL%IDATEA   = .*/NL%IDATEA   = 01/" ED2IN # Set first day
		sed -i "s/NL%IYEARH   = .*/NL%IYEARH   = 1850/" ED2IN # Set first year
		sed -i "s/NL%IMONTHH  = .*/NL%IMONTHH  = 06/" ED2IN # Set first month
		sed -i "s/NL%IDATEH   = .*/NL%IDATEH   = 01/" ED2IN # Set first day

        sed -i "s/NL%IYEARZ   = .*/NL%IYEARZ   = ${finalyear}/" ED2IN # Set last year
        sed -i "s/NL%IMONTHZ  = .*/NL%IMONTHZ  = 01/" ED2IN # Set last month
        sed -i "s/NL%IDATEZ   = .*/NL%IDATEZ   = 01/" ED2IN # Set last day

        sed -i "s/NL%IED_INIT_MODE   = .*/NL%IED_INIT_MODE   = 3/" ED2IN # change from bare ground to .css/.pss run
        sed -i "s,SFILIN   = .*,SFILIN   = '${SAS_dir}${SITE}/${SITE}',g" ED2IN # set initial file path to the SAS spin folder
        sed -i "s/NL%INCLUDE_FIRE    = 0.*/NL%INCLUDE_FIRE    = 2/" ED2IN # turn on fire
        sed -i "s/NL%SM_FIRE         = 0.*/NL%SM_FIRE         = 0.007/" ED2IN # adjust fire threshold
        sed -i "s/NL%TREEFALL_DISTURBANCE_RATE  = 0.*/NL%TREEFALL_DISTURBANCE_RATE  = 0.004/" ED2IN # turn on treefall

		# submission script changes
	    sed -i "s,$init_dir,$finish_dir,g" paleon_ed2_smp_geo.sh # change the baseline file path in submit
		sed -i "s/omp .*/omp 12/" paleon_ed2_smp_geo.sh # run the spin finish on 12 cores (splits by patch)
		sed -i "s/OMP_NUM_THREADS=.*/OMP_NUM_THREADS=12/" paleon_ed2_smp_geo.sh # run the spin finish on 12 cores (splits by patch)
        sed -i "s/h_rt=.*/h_rt=40:00:00/" paleon_ed2_smp_geo.sh # Sets the run time around what we should need

		# spin spawn start changes -- 
		# Note: spins require a different first script because they won't have any 
		#       histo files to read
		cp ${setup_dir}spawn_startloops_spinstart.sh .
		cp ${setup_dir}sub_spawn_restarts_spinstart.sh .
		sed -i "s/USER=.*/USER=${USER}/" spawn_startloops_spinstart.sh
		sed -i "s/SITE=.*/SITE=${SITE}/" spawn_startloops_spinstart.sh 		
		sed -i "s/finalyear=.*/finalyear=${finalfull}/" spawn_startloops_spinstart.sh 		
	    sed -i "s,/dummy/path,${file_path},g" spawn_startloops_spinstart.sh # set the file path
	    sed -i "s,sub_post_process.sh,sub_post_process_spinfinish.sh,g" spawn_startloops_spinstart.sh # set the file path
	    sed -i "s,/dummy/path,${file_path},g" sub_spawn_restarts_spinstart.sh # set the file path
	    sed -i "s,TEST,check_${SITE},g" sub_spawn_restarts_spinstart.sh # change job name
        sed -i "s/h_rt=.*/h_rt=48:00:00/" sub_spawn_restarts_spinstart.sh # Sets the run time around what we should need

		# spawn restarts changes
		cp ${setup_dir}spawn_startloops.sh .
		cp ${setup_dir}sub_spawn_restarts.sh .
		sed -i "s/USER=.*/USER=${USER}/" spawn_startloops.sh
		sed -i "s/SITE=.*/SITE=${SITE}/" spawn_startloops.sh 		
		sed -i "s/finalyear=.*/finalyear=${finalfull}/" spawn_startloops.sh 		
	    sed -i "s,/dummy/path,${file_path},g" spawn_startloops.sh # set the file path
	    sed -i "s,sub_post_process.sh,sub_post_process_spinfinish.sh,g" spawn_startloops.sh # set the file path
	    sed -i "s,/dummy/path,${file_path},g" sub_spawn_restarts.sh # set the file path
	    sed -i "s,TEST,check_${SITE},g" sub_spawn_restarts.sh # change job name
        sed -i "s/h_rt=.*/h_rt=48:00:00/" sub_spawn_restarts.sh # Sets the run time around what we should need

		# adjust integration step changes
		cp ${setup_dir}adjust_integration_restart.sh .
		cp ${setup_dir}sub_adjust_integration.sh .
		sed -i "s/USER=.*/USER=${USER}/" adjust_integration_restart.sh
		sed -i "s/SITE=.*/SITE=${SITE}/" adjust_integration_restart.sh 		
	    sed -i "s,/dummy/path,${file_path},g" sub_adjust_integration.sh # set the file path
	    sed -i "s,TEST,adjust_${SITE},g" sub_adjust_integration.sh # change job name
        sed -i "s/h_rt=.*/h_rt=24:00:00/" sub_adjust_integration.sh # Sets the run time around what we should need
		
		# post-processing
		cp ../../post_process_spinfinish.sh .
		cp ../../sub_post_process_spinfinish.sh .
		cp ${setup_dir}submit_ED_extraction.sh .
		cp ${setup_dir}extract_output_paleon.R .
		paleon_out=${file_path}/${SITE}_paleon		
	    sed -i "s,TEST,post_${SITE},g" sub_post_process_spinfinish.sh # change job name
	    sed -i "s,/dummy/path,${file_path},g" sub_post_process_spinfinish.sh # set the file path
		sed -i "s/SITE=.*/SITE=${SITE}/" post_process_spinfinish.sh 		
		sed -i "s/job_name=.*/job_name=extract_${SITE}/" post_process_spinfinish.sh 		
		sed -i "s,/dummy/path,${paleon_out},g" post_process_spinfinish.sh # set the file path

	    sed -i "s,TEST,extract_${SITE},g" submit_ED_extraction.sh # change job name
	    sed -i "s,/dummy/path,${file_path},g" submit_ED_extraction.sh # set the file path
		sed -i "s/site=.*/site='${SITE}'/" extract_output_paleon.R
	    sed -i "s,/dummy/path,${file_path},g" extract_output_paleon.R # set the file path
	    
	    
		# Clean up the spin initials since we don't need them anymore
		cp ${setup_dir}cleanup_spininit.sh .
		cp ${setup_dir}sub_cleanup_spininit.sh .
	    sed -i "s,/DUMMY/PATH,${init_dir}${SITE}/,g" cleanup_spininit.sh # set the file path
		sed -i "s/SITE=.*/SITE=${SITE}/" cleanup_spininit.sh 		
	    sed -i "s/lastyear=.*/lastyear=${finalinit}/" cleanup_spininit.sh 		
	    sed -i "s,/dummy/path,${file_path},g" sub_cleanup_spininit.sh # set the file path
	    sed -i "s,TEST,clean_${SITE}_spininit,g" sub_cleanup_spininit.sh # change job name

 		#qsub sub_spawn_restarts_spinstart.sh
 		
 		#qsub sub_cleanup_spininit.sh

	popd

	chmod -R a+rwx ${file_path}
	
done
