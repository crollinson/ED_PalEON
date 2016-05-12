#!/bin/csh
#PBS -N TEST
#PBS -W group_list=davidjpmoore
#PBS -q windfall
#PBS -l jobtype=serial
#PBS -l select=1:ncpus=1:mem=1gb
#PBS -l walltime=24:00:00
#PBS -l cput=24:00:00

cd /dummy/path

source /usr/share/Modules/init/bash

sh cleanup_spinfinish.sh
