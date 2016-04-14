#!/bin/sh
#$ -wd /rsgrps/davidjpmoore/projects/ED_PalEON/MIP2_Region/4_runs/
#$ -j y
#$ -S /bin/bash
#$ -V
#$ -m e
#$ -M crollinson@gmail.com
#$ -l h_rt=24:00:00
#$ -q "geo*"
#$ -N site2region
#cd /rsgrps/davidjpmoore/projects/ED_PalEON/MIP2_Region/4_runs/
R CMD BATCH site2region.R