#!/bin/csh
#PBS -N SAS
#PBS -l nodes=1:ppn=1
#PBS -l walltime=24:00:00
#PBS -m e
#PBS -M crollinson@gmail.com

cd /rsgrps/davidjpmoore/projects/ED_PalEON/MIP2_Region/2_SAS/

R CMD BATCH compile_SAS_runs.R
