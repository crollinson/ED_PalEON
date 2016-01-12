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


# Define constants & file paths for the scripts
# Note: do not need to re
file_base=/projectnb/dietzelab/paleon/ED_runs/MIP2_Region # whatever you want the base output file path to be

ed_exec=/usr2/postdoc/crolli/ED2/ED/build/ed_2.1-opt # Location of the ED Executable
init_dir=${file_base}/1_spin_initial/phase2_spininit.v1/ # Directory of initial spin files
SAS_dir=${file_base}/2_SAS/SAS_init_files.v1/ # Directory of SAS initialization files
finish_dir=${file_base}/3_spin_finish/phase2_spinfinish.v1/ # Where the transient runs will go

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

for SITE in ${cells[@]}
do
	# Site Name and Lat/Lon
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

        sed -i "s/NL%IYEARZ   = .*/NL%IYEARZ   = 2851/" ED2IN # Set last year
        sed -i "s/NL%IMONTHZ  = .*/NL%IMONTHZ  = 01/" ED2IN # Set last month
        sed -i "s/NL%IDATEZ   = .*/NL%IDATEZ   = 01/" ED2IN # Set last day

        sed -i "s/NL%IED_INIT_MODE   = 0/NL%IED_INIT_MODE   = 3/" ED2IN # change from bare ground to .css/.pss run
        sed -i "s,SFILIN   = .*,SFILIN   = '${SAS_dir}${SITE}/${SITE}',g" ED2IN # set initial file path to the SAS spin folder
        sed -i "s/NL%INCLUDE_FIRE    = 0.*/NL%INCLUDE_FIRE    = 2/" ED2IN # turn on fire
        sed -i "s/NL%SM_FIRE         = 0.*/NL%SM_FIRE         = 0.007/" ED2IN # adjust fire threshold
        sed -i "s/NL%TREEFALL_DISTURBANCE_RATE  = 0.*/NL%TREEFALL_DISTURBANCE_RATE  = 0.004/" ED2IN # turn on treefall

		# submission script changes
	    sed -i "s,$init_dir,$finish_dir,g" paleon_ed2_smp_geo.sh # change the baseline file path in submit
		sed -i "s/omp .*/omp 16/" paleon_ed2_smp_geo.sh # run the spin finish on 12 cores (splits by patch)
		sed -i "s/OMP_NUM_THREADS=.*/OMP_NUM_THREADS=16/" paleon_ed2_smp_geo.sh # run the spin finish on 12 cores (splits by patch)

 		qsub paleon_ed2_smp_geo.sh
	popd
done