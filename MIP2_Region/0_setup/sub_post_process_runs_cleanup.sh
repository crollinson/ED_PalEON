#!/bin/sh
#$ -wd /dummy/path
#$ -j y 
#$ -S /bin/bash         
#$ -V 
#$ -q "geo*"
#$ -m e
#$ -M crollinson@gmail.com
#$ -l h_rt=24:00:00
#$ -N TEST
#cd /dummy/path
sh post_process_runs_cleanup.sh