#!/bin/sh
#$ -wd /work/03911/tg832103/ED_PalEON/MIP2_Region/0_setup/
#$ -j y
#$ -S /bin/bash
#$ -V
#$ -m e
#$ -M crollinson@gmail.com
#$ -l h_rt=48:00:00
#$ -N ED_Met
#cd /work/03911/tg832103/ED_PalEON/MIP2_Region/0_setup/
R CMD BATCH process_paleon_met_region.R