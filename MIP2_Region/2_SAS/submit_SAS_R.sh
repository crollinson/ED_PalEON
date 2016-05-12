#!/bin/csh
#PBS -N SAS
#PBS -W group_list=davidjpmoore
#PBS -q standard
#PBS -l jobtype=serial
#PBS -l select=1:ncpus=1:mem=1gb
#PBS -l walltime=24:00:00
#PBS -l cput=24:00:00
#PBS -m e
#PBS -M crollinson@email.arizona.edu

cd /rsgrps/davidjpmoore/projects/ED_PalEON/MIP2_Region/2_SAS/

source /usr/share/Modules/init/bash

module load R/3.2.1
module load netcdf/4.1.3

export R_LIBS=/home/u7/crollinson/R_libs

R CMD BATCH compile_SAS_runs.R
