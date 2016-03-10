#!/bin/sh
#$ -wd /dummy/path
#$ -j y 
#$ -S /bin/bash         
#$ -V 
#$ -q "geo*"
#$ -l hostname=!scc-c*&!scc-t*
#$ -m e
#$ -M crollinson@gmail.com
#$ -l h_rt=120:00:00
#$ -N TEST
#cd /dummy/path
sh spawn_startloops.sh