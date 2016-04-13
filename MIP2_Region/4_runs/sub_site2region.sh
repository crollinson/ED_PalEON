#!/bin/sh
#$ -wd /projectnb/dietzelab/paleon/ED_runs/MIP2_Region/4_runs/
#$ -j y
#$ -S /bin/bash
#$ -V
#$ -m e
#$ -M crollinson@gmail.com
#$ -l h_rt=24:00:00
#$ -q "geo*"
#$ -N TEST
#cd /projectnb/dietzelab/paleon/ED_runs/MIP2_Region/4_runs/
R CMD BATCH site2region.R