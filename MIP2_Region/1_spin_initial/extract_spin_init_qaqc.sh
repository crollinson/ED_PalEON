#!bin/bash
# This file runs the extraction of the standard PalEON variables to they can be graphed and checked for QA/QC
# Christy Rollinson, crollinson@gmail.com

# Things to specify
# cells = list of sites you're doing QAQC on

# Order of Operations
# 1. copy extraction submit template here
# 2. Replace directory & site information for the specific site(s) of interest
# 3. Submit job


# List of cells we want to look at
cells=(lat42.75lon-72.25 lat46.25lon-94.75 lat45.25lon-68.75 lat46.25lon-89.75)

# Define the baseline file path of interest
file_base=/projectnb/dietzelab/paleon/ED_runs/MIP2_Region # whatever you want the base output file path to be

# Where the files we want to qa/qc actually are and where they'll go
setup_dir=${file_base}/0_setup # Where some constant setup files are
file_dir=${file_base}/1_spin_initial/phase2_spininit.v1/ # Where the output is
out_dir=${file_base}/1_spin_initial/spininit_qaqc.v1/ # Where everything will go
mkdir -p $out_dir


for SITE in ${cells[@]} 
do

	mkdir -p $out_dir/${SITE}

	pushd $out_dir/${SITE}
		# Creating the default file structure and copying over the base files to be modified
		cp $setup_dir/extract_ED_output.R .

		# Modify for the site	    
	    sed -i "s,site=.*,site=$SITE,g" extract_ED_output.R #site=.*
	    sed -i "s,raw.dir <-.*,raw.dir <- $file_dir/${SITE},g" extract_ED_output.R #raw.dir <- .*
	    sed -i "s,new.dir <-.*,new.dir <- $out_dir/${SITE},g" extract_ED_output.R #new.dir <- .*
		
 		R CMD BATCH extract_ED_output.R
	popd
done