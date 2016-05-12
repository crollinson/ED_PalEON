#!/bin/csh
#PBS -N Untar
#PBS -W group_list=davidjpmoore
#PBS -m e
#PBS -M crollinson@email.arizona.edu
#PBS -q windfall
#PBS -l jobtype=serial
#PBS -l select=1:ncpus=1:mem=2gb
#PBS -l walltime=24:00:00
#PBS -l cput=24:00:00

cd /rsgrps/davidjpmoore/projects/ED_PalEON/MIP2_Region/0_setup

source /usr/share/Modules/init/bash

sh untar_runs_analy.sh
