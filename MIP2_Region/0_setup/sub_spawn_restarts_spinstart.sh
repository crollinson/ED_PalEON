#!/bin/csh
#PBS -N TEST
#PBS -W group_list=davidjpmoore
#PBS -q standard
#PBS -l jobtype=serial
#PBS -l select=1:ncpus=1:mem=1gb
#PBS -l walltime=120:00:00
#PBS -l cput=120:00:00

cd /dummy/path

source /usr/share/Modules/init/bash

sh spawn_startloops_spinstart.sh
