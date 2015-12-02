#!/bin/sh
#$ -wd /projectnb/dietzelab/paleon/ED_runs/met_drivers/
#$ -j y
#$ -S /bin/bash
#$ -V
#$ -m e
#$ -M crollinson@gmail.com
#$ -l h_rt=48:00:00
#$ -N ED_Met
#cd /projectnb/dietzelab/paleon/ED_runs/met_drivers/
R CMD BATCH process_paleon_met_region.R