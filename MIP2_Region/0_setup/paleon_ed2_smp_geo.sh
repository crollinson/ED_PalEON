#!/bin/csh
#PBS -N TEST
#PBS -W group_list=davidjpmoore
#PBS -q standard
#PBS -l jobtype=small_smp
#PBS -l select=1:ncpus=4:mem=7gb
#PBS -l walltime=120:00:00
#PBS -l cput=480:00:00

source /usr/share/Modules/init/csh
module load hdf5/1.8.12

setenv OMP_NUM_THREADS 4


cd /dummy/path

./ed_2.1-opt
