#!/bin/sh
#$ -wd /projectnb/dietzelab/paleon/ED_runs//MIP2_Region/0_setup/
#$ -j y
#$ -S /bin/bash
#$ -V
#$ -m e
#$ -M crollinson@gmail.com
#$ -l h_rt=48:00:00
#$ -N ED_Metspin
#cd /projectnb/dietzelab/paleon/ED_runs/MIP2_Region/0_setup/
R CMD BATCH process_paleon_met_region_spinup.R