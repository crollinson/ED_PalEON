#!/bin/sh
#$ -wd /projectnb/dietzelab/paleon/ED_runs/phase2_spininit.v1/TEST
#$ -j y 
#$ -S /bin/bash         
#$ -V 
#$ -pe omp 12
#$ -m e
#$ -M crollinson@gmail.com
#$ -l h_rt=72:00:00
#$ -N TEST
#cd /projectnb/dietzelab/paleon/ED_runs/phase2_spinintit.v1/TEST
./ed_2.1-opt
