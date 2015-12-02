#!bin/bash
#This file sets up the directories for the runs with the .css and .pss SAS output 
#Jaclyn Hatala Matthes, 2/20/14
#jaclyn.hatala.matthes@gmail.com

sites=(PBL PDL PHA PHO PMB PUN)
startyear=1850
runtype="'HISTORY'"
outdir=/projectnb/dietzelab/paleon/ED_runs/phase1a_runs.v2/
cpdir=/projectnb/dietzelab/paleon/ED_runs/phase1a_spinfinish.v2/

if [ ! -d ${outdir} ]
then
    mkdir -p ${outdir}
fi

for SITE in ${sites[@]}
do
    #make site output directory
    if [ ! -d ${outdir}$SITE/ ]
    then
        mkdir -p ${outdir}/$SITE/
    fi
    
	#copy files and make directories for each run
    cp ${cpdir}$SITE/ED2IN ${outdir}/$SITE/
    cp ${cpdir}$SITE/paleon_ed2_geo.sh ${outdir}/$SITE/
    cp ${cpdir}$SITE/PL_MET_HEADER ${outdir}/$SITE/
    cp ${cpdir}$SITE/PalEON_Phase1a.v2.xml ${outdir}/$SITE/
    mkdir ${outdir}$SITE/histo
    mkdir ${outdir}$SITE/analy
    
	#edit ED2IN file with correct params & path
    pushd ${outdir}$SITE/
    ln -s /usr2/postdoc/crolli/ED2/ED/build/ed_2.1-opt .
    newbase=${outdir}$SITE
    oldbase=${cpdir}$SITE
    newpath1="'${outdir}${SITE}/analy/${SITE}'"
    newpath2="'${outdir}${SITE}/histo/${SITE}'"
    oldpath1="'${cpdir}$SITE/analy/${SITE}'"
    oldpath2="'${cpdir}$SITE/histo/${SITE}'"

    sed -i "s/IYEARA   = [1-9][0-9][0-9][0-9]/IYEARA   = $startyear/" ED2IN #change start year value
    sed -i "s/RUNTYPE  = 'INITIAL'/RUNTYPE  = $runtype/" ED2IN #change run type (INITIAL or HISTORY)
    sed -i "s,$oldpath1,$newpath1,g" ED2IN #change output paths
    sed -i "s,$oldpath2,$newpath2,g" ED2IN #change output paths
    sed -i 's/IED_INIT_MODE   = 3/IED_INIT_MODE   = 5/' ED2IN #change init mode from history to css/pss run
    sed -i "s,$oldbase.*,$newbase,g" paleon_ed2_geo.sh #change path in submit script
    sed -i "s,${SITE},${SITE}${rep},g" paleon_ed2_geo.sh #change job name
    popd
done






