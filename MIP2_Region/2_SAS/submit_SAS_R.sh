#!/bin/sh
#$ -wd /projectnb/dietzelab/paleon/ED_runs/MIP2_Region/2_SAS/
#$ -j y
#$ -S /bin/bash
#$ -V
#$ -m e
#$ -M crollinson@gmail.com
#$ -l h_rt=24:00:00
#$ -N SAS
#cd /projectnb/dietzelab/paleon/ED_runs/MIP2_Region/2_SAS/

R CMD BATCH compile_SAS_runs.R