#!/bin/csh
#PBS -N TEST
#PBS -W group_list=davidjpmoore
#PBS -q standard
#PBS -l jobtype=serial
#PBS -l select=1:ncpus=1:mem=1gb
#PBS -l walltime=24:00:00
#PBS -l cput=24:00:00

cd /dummy/path

sh adjust_integration_restart.sh
