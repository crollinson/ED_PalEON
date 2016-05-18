#!/bin/sh
#$ -wd /dummy/path
#$ -j y 
#$ -S /bin/bash         
#$ -V 
#$ -l h_rt=120:00:00
#$ -N TEST
#cd /dummy/path
sh adjust_integration_restart.sh