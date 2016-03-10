#!/bin/bash
# submits the script that cleans up files from the previous step
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
sh cleanup_spininit.sh