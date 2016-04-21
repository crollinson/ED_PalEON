#!/bin/bash
#PBS -N ED_MetSpin
#PBS -m e
#PBS -M crollinson@gmail.com
#PBS -l nodes=1:ppn=1
#PBS -l walltime=48:00:00

cd /bigdata/jsteinkamp/ED/ED_PalEON/MIP2_Region/0_setup/

R CMD BATCH process_paleon_met_region_spinup.R
