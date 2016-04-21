#!/bin/bash
#PBS -N TEST
#PBS -l nodes=1:ppn=4
#PBS -l walltime=100:00:00

export OMP_NUM_THREADS 4

cd /dummy/path

./ed_2.1-opt
