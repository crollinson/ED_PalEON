#!/bin/bash
#PBS -N TEST
#PBS -l nodes=1:ppn=1
#PBS -l walltime=24:00:00

cd /dummy/path

sh reprocess_runs.sh
