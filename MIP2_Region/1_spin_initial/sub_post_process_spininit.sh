#!/bin/sh
#$ -wd /dummy/path
#$ -j y 
#$ -S /bin/bash         
#$ -V 
#$ -q "geo*"
#$ -l h_rt=24:00:00
#$ -N TEST
#cd /dummy/path
sh post_process_spininit.sh