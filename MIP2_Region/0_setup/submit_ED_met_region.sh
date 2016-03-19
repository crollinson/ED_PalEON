#!/bin/sh
#$ -wd /projectnb/dietzelab/paleon/ED_runs/MIP2_Region/0_setup/
#$ -j y
#$ -S /bin/bash
#$ -V
#$ -l h_rt=48:00:00
#$ -N ED_Met
#cd /projectnb/dietzelab/paleon/ED_runs/MIP2_Region/0_setup/
R CMD BATCH process_paleon_met_region.R