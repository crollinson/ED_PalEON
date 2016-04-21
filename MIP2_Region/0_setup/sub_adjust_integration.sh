#!/bin/bash
#PBS -N TEST
#PBS -l nodes=1:ppn=12
#PBS -l walltime=24:00:00

cd /dummy/path

sh adjust_integration_restart.sh
