#!/bin/bash
#PBS -N TEST
#PBS -m e
#PBS -M crollinson@gmail.com
#PBS -l nodes=1:ppn=1
#PBS -l walltime=24:00:00

cd /dummy/path

R CMD BATCH extract_output_paleon.R
