#!/bin/csh
#PBS -N SAS
#PBS -l nodes=1:ppn=1
#PBS -l walltime=24:00:00
#PBS -m e
#PBS -M crollinson@gmail.com

cd /bigdata/jsteinkamp/ED/ED_PalEON/MIP2_Region/2_SAS/S

R CMD BATCH compile_SAS_runs.R
