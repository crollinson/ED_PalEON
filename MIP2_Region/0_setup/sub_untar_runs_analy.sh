#!/bin/bash
#PBS -N Untar
#PBS -m e
#PBS -M crollinson@gmail.com
#PBS -l nodes=1:ppn=1
#PBS -l walltime=24:00:00

cd /bigdata/jsteinkamp/ED/ED_PalEON/MIP2_Region/0_setup

sh untar_runs_analy.sh
