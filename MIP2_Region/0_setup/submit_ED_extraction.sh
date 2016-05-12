#!/bin/csh
#PBS -N TEST
#PBS -W group_list=davidjpmoore
#PBS -m e
#PBS -M crollinson@email.arizona.edu
#PBS -q standard
#PBS -l jobtype=serial
#PBS -l select=1:ncpus=1:mem=2gb
#PBS -l walltime=24:00:00
#PBS -l cput=24:00:00

cd /dummy/path
source /usr/share/Modules/init/bash

module load R/3.2.1
module load netcdf/4.1.3

export R_LIBS=/home/u7/crollinson/R_libs

R CMD BATCH extract_output_paleon.R
