#!/bin/bash
#PBS -N TEST
#PBS -l nodes=1:ppn=1
#PBS -l walltime=24:00:00

cd /dummy/path

function qsub {
  ssh login cd ${PWD} \&\& /usr/bin/qsub $@
}

sh cleanup_spinfinish.sh
