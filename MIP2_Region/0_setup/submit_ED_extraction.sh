#!/bin/sh
#$ -wd /dummy/path
#$ -j y
#$ -S /bin/bash
#$ -V
#$ -l h_rt=24:00:00
#$ -N TEST
#cd /dummy/path
R CMD BATCH extract_output_paleon.R