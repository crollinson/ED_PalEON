#!/bin/sh
#$ -wd /rsgrps/davidjpmoore/projects/ED_PalEON/MIP2_Region/0_setup
#$ -j y 
#$ -S /bin/bash         
#$ -V 
#$ -q "geo*"
#$ -l h_rt=48:00:00
#$ -N Untar
#cd /rsgrps/davidjpmoore/projects/ED_PalEON/MIP2_Region/0_setup
sh untar_runs_analy.sh