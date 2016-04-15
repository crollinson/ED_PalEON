#!/bin/csh
#PBS -N TEST
#PBS -W group_list=davidjpmoore
#PBS -m e
#PBS -M crollinson@gmail.com
#PBS -q standard
#PBS -l jobtype=serial
#PBS -l select=1:ncpus=1:mem=1.5gb
#PBS -l walltime=24:00:00
#PBS -l cput=24:00:00

cd /dummy/path

R CMD BATCH extract_output_paleon.R
