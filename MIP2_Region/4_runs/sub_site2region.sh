#!/bin/csh
#PBS -N site2region
#PBS -W group_list=davidjpmoore
#PBS -q windfall
#PBS -l jobtype=serial
#PBS -l select=1:ncpus=1:mem=2gb
#PBS -l walltime=24:00:00
#PBS -l cput=24:00:00
#PBS -m e
#PBS -M crollinson@email.arizona.edu

cd /rsgrps/davidjpmoore/projects/ED_PalEON/MIP2_Region/4_runs/

source /usr/share/Modules/init/bash

R CMD BATCH site2region.R
