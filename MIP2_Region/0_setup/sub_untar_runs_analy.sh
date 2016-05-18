#!/bin/sh
#$ -wd /afs/crc.nd.edu/user/c/crollin1/ED_PalEON/MIP2_Region/0_setup
#$ -j y 
#$ -S /bin/bash         
#$ -V 
#$ -l h_rt=48:00:00
#$ -N Untar
#cd /afs/crc.nd.edu/user/c/crollin1/ED_PalEON/MIP2_Region/0_setup
sh untar_runs_analy.sh