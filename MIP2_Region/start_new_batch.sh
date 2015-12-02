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
# 1) Read in file order
# 2) determine which cells have already been done (directory names in file.dir)
# 3) loop through the next n cells and adjust base ED2IN for specific characters
#    Things to be Modified per site:
#     -  NL%POI_LAT  =  
#     -  NL%POI_LON  = 
#     -  NL%FFILOUT = '/projectnb/dietzelab/paleon/ED_runs/phase2_spininit.v1/XXXXX/analy/XXXXX'
#     -  NL%SFILOUT = '/projectnb/dietzelab/paleon/ED_runs/phase2_spininit.v1/XXXXX/histo/XXXXX'
#     -  NL%SFILIN  = '/projectnb/dietzelab/paleon/ED_runs/phase2_spininit.v1/XXXXX/histo/XXXXX'
#     -  NL%SLXCLAY = 
#     -  NL%SLXSAND = 



module load nco/4.3.4

# Define constants & file paths for the script
file_dir=/projectnb/dietzelab/paleon/ED_runs/phase2_spininit.v1
grid_order=/projectnb/dietzelab/paleon/ED_runs/phase2_spininit.v1/Paleon_MIP_Phase2_ED_Order.csv
file_clay=/projectnb/dietzelab/paleon/env_regional/phase2_env_drivers_v2/soil/paleon_soil_t_clay.nc
file_sand=/projectnb/dietzelab/paleon/env_regional/phase2_env_drivers_v2/soil/paleon_soil_t_sand.nc
n=1

# Get the list of what grid cells have already been done
pushd $file_dir
	file_done=(lat*)
popd

# Extract the file names we should be making form the csv file
cells=($(awk -F ',' 'NR>1 {print "lat" $1 "lon" $2}' $grid_order))
lat=($(awk -F ',' 'NR>1 {print $2}' $grid_order))
lon=($(awk -F ',' 'NR>1 {print $1}' $grid_order))

# # One way to remove cells is to loop through all file names to explicitly make sure 
# # we're not duplicating or skipping anything.  This is the way to go if we've messed with
# # cell orders, but can be quite slow.
# for REMOVE in ${file_done[@]}
# do 
# 	cells=(${cells[@]/$REMOVE/})
# done

# An alternate way to do it that works if we don't skip anything
n_done=$((${#file_done[@]}))
n_cells=${#cells[@]}
cells=(${cells[@]:$n_done:$n})
lat=(${lat[@]:$n_done:$n})
lon=(${lon[@]:$n_done:$n})

# for FILE in $(seq 0 (($n-1)))
for ((FILE=0; FILE<$n; FILE++)) # This is a way of doing it so that we don't have to modify N
do
	# Site Name and Lat/Lon
	SITE=${cells[FILE]}
	echo $SITE

	lat_now=${lat[FILE]}
	lon_now=${lon[FILE]}
	lat_min=$(bc<<<"$lat_now-0.25")
	lat_max=$(bc<<<"$lat_now+0.25")
	lon_min=$(bc<<<"$lon_now-0.25")
	lon_max=$(bc<<<"$lon_now+0.25")

	# Extract percent clay and percent sand
	# 1) extract and store as a temporary clay & sand .nc file
	# 2) extract those single values and store it as an object
	# 3) convert percentage into a fraction
	# 4) file cleanup: get rid of temp clay & sand
	ncea -O -d latitude,$lat_min,$lat_max -d longitude,$lon_min,$lon_max $file_clay clay_temp.nc 
	ncea -O -d latitude,$lat_min,$lat_max -d longitude,$lon_min,$lon_max $file_sand sand_temp.nc 
	clay=$(ncdump clay_temp.nc |awk '/t_clay =/ {nextline=NR+1}{if(NR==nextline){print $1}}')
	sand=$(ncdump sand_temp.nc |awk '/t_sand =/ {nextline=NR+1}{if(NR==nextline){print $1}}')
	clay=$(bc<<<"$clay*0.01")
	sand=$(bc<<<"$sand*0.01")

	rm -f clay_temp.nc sand_temp.nc

	# File Paths
    new_analy="'${file_dir}${SITE}/analy/${SITE}'"
    new_histo="'${file_dir}${SITE}/histo/${SITE}'"
    old_analy="'${file_dir}TEST/analy/TEST'"
    old_histo="'${file_dir}TEST/histo/TEST'"
    newbase=${file_dir}/$SITE
    oldbase=${file_dir}/TEST
	oldname=TESTinit


	file_path=${file_dir}/${SITE}

	mkdir -p ${file_path} 
	
	pushd ${file_path}
		# Creating the default file structure and copying over the base files to be modified
		mkdir -p histo analy
		ln -s /usr2/postdoc/crolli/ED2/ED/build/ed_2.1-opt
		cp ../ED2IN_SpinInit_Base ED2IN
		cp ../PalEON_Phase1a.v4.xml .
		cp ../paleon_ed2_smp_geo.sh .

		# ED2IN Changes
	    sed -i "s,$old_analy,$new_analy,g" ED2IN #change output paths
	    sed -i "s,$old_histo,$new_histo,g" ED2IN #change output paths
        sed -i "s/POI_LAT  =.*/POI_LAT  = $lat_now/" ED2IN # set site latitude
        sed -i "s/POI_LON  =.*/POI_LON  = $lon_now/" ED2IN # set site longitude
        sed -i "s/SLXCLAY =.*/SLXCLAY = $clay/" ED2IN # set fraction soil clay
        sed -i "s/SLXSAND =.*/SLXSAND = $sand/" ED2IN # set fraction soil sand


	    sed -i "s,$oldbase.*,$newbase,g" paleon_ed2_smp_geo.sh #change path in submit script
	    sed -i "s,TEST,${SITE}${rep},g" paleon_ed2_smp_geo.sh #change job name
		
		qsub paleon_ed2_smp_geo.sh
	popd
done