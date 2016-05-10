#!/bin/sh
#$ -wd /afs/crc.nd.edu/user/c/crollin1/ED_PalEON/MIP2_Region/2_SAS/
#$ -j y
#$ -S /bin/bash
#$ -V
#$ -m e
#$ -M crollinson@gmail.com
#$ -l h_rt=24:00:00
#$ -N SAS
#cd /afs/crc.nd.edu/user/c/crollin1/ED_PalEON/MIP2_Region/2_SAS/

R CMD BATCH compile_SAS_runs.R