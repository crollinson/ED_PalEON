#!/bin/csh
#PBS -N ED_MetSpin
#PBS -W group_list=davidjpmoore
#PBS -m e
#PBS -M crollinson@email.arizona.edu
#PBS -q standard
#PBS -l jobtype=serial
#PBS -l select=1:ncpus=1:mem=1.5gb
#PBS -l walltime=48:00:00
#PBS -l cput=48:00:00

cd /rsgrps/davidjpmoore/projects/ED_PalEON/MIP2_Region/0_setup/

R CMD BATCH process_paleon_met_region_spinup.R
