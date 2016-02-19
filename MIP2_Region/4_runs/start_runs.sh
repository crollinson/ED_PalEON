#!bin/bash
# This file takes the ending point for the spin finish (transient runs) and starts the 
# full PalEON Simulations
# Christy Rollinson, crollinson@gmail.com
# January, 2016

# Order of operations for starting the spin finish after having run the SAS script
# 1. Copy & rename last output file from transient runs
# 2. Copy ED2IN, executable, submission script, and xml file to new location
# 3. Change file paths, init mode, & turn on disturbance in ED2IN

# Things to change from the spin initial
#   all fille paths from initial spin to final spin
#   run title = Spin Finish (Post-SAS) (NL%EXPNME)
#   init mode = 5 (history file; ignoring the descriptions as they don't line up
#               with my understanding of the different innitialization methods)
#   Modify run date
#   met dates 

# Load the necessary hdf5 library
module load hdf5/1.6.10

# Define constants & file paths for the scripts
file_base=/projectnb/dietzelab/paleon/ED_runs/MIP2_Region # whatever you want the base output file path to be

ed_exec=/usr2/postdoc/crolli/ED2/ED/build/ed_2.1-opt # Location of the ED Executable
spin_dir=${file_base}/3_spin_finish/phase2_spinfinish.v1/ # Directory of initial spin files
runs_dir=${file_base}/4_runs/phase2_runs.v1/ # Where the transient runs will go
finalyear=2351 # The last year of the spin finish

n=3 # number of sites to start in this batch

# Making the file directory if it doesn't already exist
mkdir -p $runs_dir

# Get the list of what grid cells already have at least started full runs
pushd $runs_dir
	file_done=(lat*)
popd

# Get the list of what grid cells have at least started the spin finish
pushd $spin_dir
	cells=(lat*)
popd


# This will probably be slow later on, but will probably be the best way to make sure we're
# not skipping any sites
# NOTE: NEED TO COMMENT THIS PART OUT FIRST TIME THROUGH 
#       because it doesn't like no matches in file_done
#for REMOVE in ${file_done[@]}
#do 
#	cells=(${cells[@]/$REMOVE/})
#done

# Filter sites that have successfully complete the spinfinish
for SITE in ${cells[@]}
do
	#get dates of last histo file
    path=${spin_dir}${SITE}
    lastday=`ls -l -rt ${path}/histo| tail -1 | rev | cut -c15-16 | rev`
    lastmonth=`ls -l -rt ${path}/histo| tail -1 | rev | cut -c18-19 | rev`
    lastyear=`ls -l -rt ${path}/histo| tail -1 | rev | cut -c21-24 | rev`

	# If the last year isn't the last year of the spin finish, don't do it for now
	if [[(("${lastyear}" < "${finalyear}"))]]
	then
		echo "  Site not done: $SITE"
		cells=(${cells[@]/$SITE/})
	fi
done

for ((FILE=0; FILE<$n; FILE++)) # This is a way of doing it so that we don't have to modify N
do
	# Site Name and Lat/Lon
	SITE=${cells[FILE]}
	echo $SITE
	
	# Make a new folder for this site
	file_path=${runs_dir}/${SITE}/
	mkdir -p ${file_path} 
	
	pushd ${file_path}
		# Creating the default file structure and copying over the base files to be modified
		mkdir -p histo analy
		ln -s $ed_exec
		cp ${spin_dir}${SITE}/ED2IN .
		cp ${spin_dir}${SITE}/PalEON_Phase2.v1.xml .
		cp ${spin_dir}${SITE}/paleon_ed2_smp_geo.sh .


	    #Copy the last January (so we start at the appropriate phenological state)
	    lastday=`ls -l -rt ${spin_dir}${SITE}/histo| tail -1 | rev | cut -c15-16 | rev`
	    lastmonth=`ls -l -rt ${spin_dir}${SITE}/histo| tail -1 | rev | cut -c18-19 | rev`
	    lastyear=`ls -l -rt ${spin_dir}${SITE}/histo| tail -1 | rev | cut -c21-24 | rev`

		echo "     Last Spin Finish Year = $lastyear"
		if [[(("${lastmonth}" > 01))]]
		then
			lastyear=$(($lastyear-1))
		fi
		echo "     Use Spin Finish Year = $lastyear"

		cp ${spin_dir}${SITE}/histo/*-S-$lastyear-01-01-* histo/${SITE}-S-1850-01-01-000000-g01.h5 

		# ED2IN Changes	    
	    sed -i "s,$spin_dir,$runs_dir,g" ED2IN #change the baseline file path everywhere
        sed -i "s/NL%EXPNME =.*/NL%EXPNME = 'PalEON Runs (Land Use off)'/" ED2IN # change the experiment name

        sed -i "s/NL%RUNTYPE  = 'INITIAL'.*/NL%RUNTYPE  = 'HISTORY'/" ED2IN # change from bare ground to .css/.pss run

        sed -i "s/NL%IED_INIT_MODE   = .*/NL%IED_INIT_MODE   = 5/" ED2IN # change from bare ground to .css/.pss run
        sed -i "s,SFILIN   = .*,SFILIN   = '${runs_dir}${SITE}/histo/${SITE}',g" ED2IN # set initial file path to the SAS spin folder

        sed -i "s/NL%IYEARA   = .*/NL%IYEARA   = 1850/" ED2IN # Set runs start year
        sed -i "s/NL%IMONTHA  = .*/NL%IMONTHA  = 01/" ED2IN # Set runs start month
        sed -i "s/NL%IDATEA   = .*/NL%IDATEA   = 01/" ED2IN # Set runs start day

        sed -i "s/NL%IYEARZ   = .*/NL%IYEARZ   = 3011/" ED2IN # Set runs last year
        sed -i "s/NL%IMONTHZ  = .*/NL%IMONTHZ  = 01/" ED2IN # Set runs last month
        sed -i "s/NL%IDATEZ   = .*/NL%IDATEZ   = 01/" ED2IN # Set runs last day

        sed -i "s/NL%IYEARH   = .*/NL%IYEARH   = 1850/" ED2IN # Set histo year
        sed -i "s/NL%IMONTHH  = .*/NL%IMONTHH  = 01/" ED2IN # Set histo month
        sed -i "s/NL%IDATEH   = .*/NL%IDATEH   = 01/" ED2IN # Set histo day

        sed -i "s/NL%METCYC1     =.*/NL%METCYC1     = 1850/" ED2IN # Set met start
        sed -i "s/NL%METCYCF     =.*/NL%METCYCF     = 3010/" ED2IN # Set met end


		# submission script changes
	    sed -i "s,$spin_dir,$runs_dir,g" paleon_ed2_smp_geo.sh # change the baseline file path in submit
		sed -i "s/omp .*/omp 12/" paleon_ed2_smp_geo.sh # run the spin finish on 12 cores (splits by patch)
		sed -i "s/OMP_NUM_THREADS=.*/OMP_NUM_THREADS=12/" paleon_ed2_smp_geo.sh # run the spin finish on 12 cores (splits by patch)

# 		qsub paleon_ed2_smp_geo.sh
	popd

	chmod -R a+rwx ${file_path}

done

