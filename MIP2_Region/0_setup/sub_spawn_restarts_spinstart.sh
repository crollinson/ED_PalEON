#!/bin/sh
#$ -wd /dummy/path
#$ -j y 
#$ -S /bin/bash         
#$ -V 
#$ -q "geo*"
#$ -l hostname=!scc-c*&!scc-t*
#$ -l h_rt=120:00:00
#$ -N TEST
#cd /dummy/path
sh spawn_startloops_spinstart.sh