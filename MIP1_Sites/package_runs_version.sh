#!bin/bash
# Specify in & out directories

# Script transfers & packages environmental drivers into new version
dir_in="/projectnb/dietzelab/paleon/ED_runs/phase1a_runs.v3/post-process"
dir_out="/projectnb/dietzelab/paleon/ED_runs/ED2.v7"


sites=(PHA PHO PUN PBL PDL PMB)

mkdir -p ${dir_out}

cd ${dir_in}

for SITE in ${sites[@]}
do
    echo ${SITE}
	# Adding leading 0 in file names
# 	mv ${dir_in}/${SITE}/${SITE}.ED2.850.nc ${dir_in}/${SITE}/${SITE}.ED2.0850.nc 
# 	mv ${dir_in}/${SITE}/${SITE}.ED2.900.nc ${dir_in}/${SITE}/${SITE}.ED2.0900.nc 
	
	# packaging everything into tars
    tar -jcvf ${dir_out}/${SITE}.tar.bz2 ${SITE}/
done

