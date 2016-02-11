#!/bin/sh
#$ -wd /dummy/path
#$ -j y 
#$ -S /bin/bash         
#$ -V 
#$ -pe omp 4
#$ -v OMP_NUM_THREADS=4
#$ -m e
#$ -M crollinson@gmail.com
#$ -l h_rt=120:00:00
#$ -N TEST
#cd /dummy/path
./ed_2.1-opt
