#!/bin/csh
#PBS -N TEST
#PBS -m e
#PBS -M crollinson@gmail.com
#PBS -W group_list=davidjpmoore
#PBS -q standard
#PBS -l jobtype=small_smp
#PBS -l select=1:ncpus=4:mem=4gb
#PBS -l walltime=100:00:00
#PBS -l cput=400:00:00

source /usr/share/Modules/init/csh
module load hdf5/1.10.0

setenv OMP_NUM_THREADS 4
unlimit

cd /dummy/path

./ed_2.1-opt
