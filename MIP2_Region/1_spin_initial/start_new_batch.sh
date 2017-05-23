#!bin/bash
# This file starts the next cells from the PalEON Regional ED Runs
# Christy Rollinson, crollinson@gmail.com

# Things to specify
# n          = Number of sites to start
# ED2IN_Base = template ED2IN to be modified
# file.dir   = spininit directory; used to find what sites have been done
# soil.path  = path of percent clay and percent sand to query for
#              SLXCLAY & SLXSAND, respectively
# grid.order = .csv file with the order sites should be run in to determine 
#              what sites should be done next


# Order of Operations
# 1) Sync file with order sites & status/location 
# 2) Add file directories for any sites that are remote so we don't repeat them
# 3) loop through the next n cells and adjust base ED2IN for specific characters
#    Things to be Modified per site:
#     -  NL%POI_LAT  =  
#     -  NL%POI_LON  = 
#     -  NL%FFILOUT = '~/ED_PalEON/MIP2_Region/1_spin_initial/phase2_spininit.v1/XXXXX/analy/XXXXX'
#     -  NL%SFILOUT = '~/ED_PalEON/MIP2_Region/1_spin_initial/phase2_spininit.v1/XXXXX/histo/XXXXX'
#     -  NL%SFILIN  = '~/ED_PalEON/MIP2_Region/1_spin_initial/phase2_spininit.v1/XXXXX/histo/XXXXX'
#     -  NL%SLXCLAY = 
#     -  NL%SLXSAND = 


## Load the necessary hdf5 library
# module load hdf5/1.6.10
# module load nco/4.3.4

# Define constants & file paths for the scripts
BU_base_spin=/projectnb/dietzelab/paleon/ED_runs/MIP2_Region # The base original file paths in all of my scripts
BU_base_EDI=/projectnb/dietzelab/EDI/ # The location of basic ED Inputs on the BU server

file_base=/home/crollinson/ED_PalEON/MIP2_Region # whatever you want the base output file path to be
EDI_base=/home/crollinson/ED_inputs/ # The location of basic ED Inputs for you

ed_exec=/home/crollinson/ED2/ED/build/ed_2.1-opt # Location of the ED Executable
file_dir=${file_base}/1_spin_initial/phase2_spininit.v1/ # Where everything will go
setup_dir=${file_base}/0_setup/ # Where some constant setup files are
site_file=${setup_dir}/Paleon_MIP_Phase2_ED_Order_Status.csv # # Path to list of ED sites w/ status

# # Lets double check and make sure the order status file is up to date
# # Note: need to make sure you don't have to enter a password for this to work right
# git fetch --all
# git checkout origin/master -- $site_file

file_clay=/home/crollinson/ED_PalEON/MIP2_Region/phase2_env_drivers_v2/soil/paleon_soil_t_clay.nc # Location of percent clay file
file_sand=/home/crollinson/ED_PalEON/MIP2_Region/phase2_env_drivers_v2/soil/paleon_soil_t_sand.nc # Location of percent sand file
file_depth=/home/crollinson/ED_PalEON/MIP2_Region/phase2_env_drivers_v2/soil/paleon_soil_soil_depth.nc # Location of soil depth file

finalyear=2851
finalfull=2850
n=1

# Make sure the file paths on the Met Header have been updated for the current file structure
sed -i "s,$BU_base_spin,$file_base,g" ${file_base}/0_setup/PL_MET_HEADER

# Making the file directory if it doesn't already exist
mkdir -p $file_dir

# Extract the file names of sites that haven't been started yet
sites_done=($(awk -F ',' 'NR>1 && $6!="" {print $4}' ${site_file})) # Get sites that have a location
cells=($(awk -F ',' 'NR>1 && $6=="" {print $4}' ${site_file}))
lat=($(awk -F ',' 'NR>1 && $6=="" {print $3}' ${site_file}))
lon=($(awk -F ',' 'NR>1 && $6=="" {print $2}' ${site_file}))


# for FILE in $(seq 0 (($n-1)))
for ((FILE=0; FILE<$n; FILE++)) # This is a way of doing it so that we don't have to modify N
do
	# Site Name and Lat/Lon
	SITE=${cells[FILE]}
	echo $SITE

	lat_now=${lat[FILE]}
	lon_now=${lon[FILE]}

	# -----------------------------------------------------------------------------
	# Extracting and setting soil  parameters
	# 1) extract and store as a temporary clay & sand .nc file
	# 2) extract those single values and store it as an object
	# 3) convert percentages into fraction; cm to m
	# 4) subsetting soil layers based on soil depth
	# 5) file cleanup: get rid of temp clay & sand
	# -----------------------------------------------------------------------------
	# List of baseline soil parameters
	SLZ_BASE=(-4.00 -3.00 -2.17 -1.50 -1.10 -0.80 -0.60 -0.45 -0.30 -0.20 -0.12 -0.06)
	SLMSTR_BASE=(1.00 1.00 1.00 1.00 1.00 1.00 1.00 1.00 1.00 1.00 1.00 1.00)
	STGOFF_BASE=(0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00)
	NZG=${#SLZ_BASE[@]}
	depth_min=(-0.15) # Setting an artificial minimum soil depth of 15 cm; note: this gets us a min of 3 soil layers


	# Get cell bounding box 
	lat_min=$(bc<<<"$lat_now-0.25")
	lat_max=$(bc<<<"$lat_now+0.25")
	lon_min=$(bc<<<"$lon_now-0.25")
	lon_max=$(bc<<<"$lon_now+0.25")

	# 1) extract and store as a temporary clay & sand .nc file	
	ncea -O -d latitude,$lat_min,$lat_max -d longitude,$lon_min,$lon_max $file_clay clay_temp.nc 
	ncea -O -d latitude,$lat_min,$lat_max -d longitude,$lon_min,$lon_max $file_sand sand_temp.nc 
	ncea -O -d latitude,$lat_min,$lat_max -d longitude,$lon_min,$lon_max $file_depth depth_temp.nc 

	# 2) extract those single values and store it as an object
	clay=$(ncdump clay_temp.nc |awk '/t_clay =/ {nextline=NR+1}{if(NR==nextline){print $1}}')
	sand=$(ncdump sand_temp.nc |awk '/t_sand =/ {nextline=NR+1}{if(NR==nextline){print $1}}')
	depth=$(ncdump depth_temp.nc |awk '/soil_depth =/ {nextline=NR+1}{if(NR==nextline){print $1}}')

	# 3) convert percentages into fraction; cm to m
	clay=$(bc<<<"$clay*0.01")
	sand=$(bc<<<"$sand*0.01")
	depth=$(bc<<<"$depth*-0.01")

	# ---------------------------------------------
	# 4) subsetting soil layers based on soil depth; deepest layer = soil_depth
	# ---------------------------------------------
	# If the actual soil depth is less than what we specified as the minimum, use our 
	# artificial minimum (default = 0.15 cm)

	if [[(("${depth}" < "${depth_min}"))]]
	then
		depth=$depth_min
	fi

	SLZ=()
	SLMSTR=()
	STGOFF=()
	for ((i=0; i<$NZG; i++));
	do
	if [[(("${SLZ_BASE[$i]}" < "${depth}"))]]
	then
		SLZ=(${SLZ[@]} ${SLZ_BASE[$i]},)
		SLMSTR=(${SLMSTR[@]} ${SLMSTR_BASE[$i]},)
		STGOFF=(${STGOFF[@]} ${STGOFF_BASE[$i]},)
	fi
	done

	# Defining some new index numbers
	NZG=${#SLZ[@]} # Number soil layers
	nz_last=$(($NZG - 1)) # index num of the last layer

	# Replace the deepest soil layer with soil depth
	SLZ=($depth, ${SLZ[@]:1:$nz_last})

	# Getting rid of trailing commas
	SLZ[$nz_last]=${SLZ[$nz_last]:0:5}
	SLMSTR[$nz_last]=${SLMSTR[$nz_last]:0:4}
	STGOFF[$nz_last]=${STGOFF[$nz_last]:0:4}

	# Flattening the array into a single "value"
	SLZ=$(echo ${SLZ[@]})
	SLMSTR=$(echo ${SLMSTR[@]})
	STGOFF=$(echo ${STGOFF[@]})
	echo ${SLZ}
	echo ${SLMSTR}
	echo ${STGOFF}
	# ---------------------------------------------

	# 5) file cleanup: get rid of temp clay & sand
	rm -f clay_temp.nc sand_temp.nc depth_temp.nc
	# -----------------------------------------------------------------------------

	# File Paths
    new_analy="'${file_dir}${SITE}/analy/${SITE}'"
    new_histo="'${file_dir}${SITE}/histo/${SITE}'"
    old_analy="'${file_dir}TEST/analy/TEST'"
    old_histo="'${file_dir}TEST/histo/TEST'"
    newbase=${file_dir}/$SITE
    oldbase=${file_dir}/TEST
	oldname=TESTinit


	file_path=${file_dir}/${SITE}/

	mkdir -p ${file_path} 
	
	pushd ${file_path}
		# Creating the default file structure and copying over the base files to be modified
		mkdir -p histo analy
		ln -s $ed_exec
		cp ../../ED2IN_SpinInit_Base ED2IN
		cp ${setup_dir}PalEON_Phase2.v1.xml .
		cp ${setup_dir}paleon_ed2_smp_geo.sh .

		# ED2IN Changes	    
	    sed -i "s,$BU_base_spin,$file_base,g" ED2IN #change the baseline file path everywhere
	    sed -i "s,$BU_base_EDI,$EDI_base,g" ED2IN #change the baseline file path for ED Inputs

        sed -i "s/NL%IYEARZ   = .*/NL%IYEARZ   = $finalyear/" ED2IN # Set last year
	    sed -i "s,$old_analy,$new_analy,g" ED2IN #change output paths
	    sed -i "s,$old_histo,$new_histo,g" ED2IN #change output paths
        sed -i "s/POI_LAT  =.*/POI_LAT  = $lat_now/" ED2IN # set site latitude
        sed -i "s/POI_LON  =.*/POI_LON  = $lon_now/" ED2IN # set site longitude
        sed -i "s/SLXCLAY =.*/SLXCLAY = $clay/" ED2IN # set fraction soil clay
        sed -i "s/SLXSAND =.*/SLXSAND = $sand/" ED2IN # set fraction soil sand
        sed -i "s/NZG =.*/NZG = $NZG/" ED2IN # set number soil layers
        sed -i "s/SLZ     =.*/SLZ = $SLZ/" ED2IN # set soil depths
        sed -i "s/SLMSTR  =.*/SLMSTR = $SLMSTR/" ED2IN # set initial soil moisture
        sed -i "s/STGOFF  =.*/STGOFF = $STGOFF/" ED2IN # set initial soil temp offset

		# submission script changes
	    sed -i "s,/dummy/path,${file_path},g" paleon_ed2_smp_geo.sh #site=.*
	    sed -i "s,TEST,${SITE},g" paleon_ed2_smp_geo.sh #change job name
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
	    sed -i "s,sub_post_process.sh,sub_post_process_spininit.sh,g" spawn_startloops_spinstart.sh # set the file path
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
	    sed -i "s,sub_post_process.sh,sub_post_process_spininit.sh,g" spawn_startloops.sh # set the file path
	    sed -i "s,/dummy/path,${file_path},g" sub_spawn_restarts.sh # set the file path
	    sed -i "s,TEST,check_${SITE},g" sub_spawn_restarts.sh # change job name
        sed -i "s/h_rt=.*/h_rt=48:00:00/" sub_spawn_restarts_spinstart.sh # Sets the run time around what we should need

		# adjust integration step changes
		cp ${setup_dir}adjust_integration_restart.sh .
		cp ${setup_dir}sub_adjust_integration.sh .
		sed -i "s/USER=.*/USER=${USER}/" adjust_integration_restart.sh
		sed -i "s/SITE=.*/SITE=${SITE}/" adjust_integration_restart.sh 		
	    sed -i "s,/dummy/path,${file_path},g" sub_adjust_integration.sh # set the file path
	    sed -i "s,TEST,adjust_${SITE},g" sub_adjust_integration.sh # change job name
        sed -i "s/h_rt=.*/h_rt=24:00:00/" sub_adjust_integration.sh # Sets the run time around what we should need
		
		# post-processing
		cp ../../post_process_spininit.sh .
		cp ../../sub_post_process_spininit.sh .
		cp ${setup_dir}submit_ED_extraction.sh .
		cp ${setup_dir}extract_output_paleon.R .
		paleon_out=${file_path}/${SITE}_paleon
	    sed -i "s,TEST,post_${SITE},g" sub_post_process_spininit.sh # change job name
	    sed -i "s,/dummy/path,${file_path},g" sub_post_process_spininit.sh # set the file path
		sed -i "s/SITE=.*/SITE=${SITE}/" post_process_spininit.sh 		
		sed -i "s/job_name=.*/job_name=extract_${SITE}/" post_process_spininit.sh 		
		sed -i "s,/dummy/path,${paleon_out},g" post_process_spininit.sh # set the file path

	    sed -i "s,TEST,extract_${SITE},g" submit_ED_extraction.sh # change job name
	    sed -i "s,/dummy/path,${file_path},g" submit_ED_extraction.sh # set the file path
		sed -i "s/site=.*/site='${SITE}'/" extract_output_paleon.R
	    sed -i "s,/dummy/path,${file_path},g" extract_output_paleon.R # set the file path


#  		sh spawn_startloops_spinstart.sh
	popd	

	chmod -R a+rwx ${file_path}

done

# git stash # stash the pulled file so we don't get confilcts

