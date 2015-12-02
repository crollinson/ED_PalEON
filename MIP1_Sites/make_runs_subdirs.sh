#!bin/bash
#This file sets up the directories for the runs
# NOTE: Need to copy the ED2IN from your own files 
#Jaclyn Hatala Matthes, 2/20/14
#jaclyn.hatala.matthes@gmail.com

sites=(PBL PDL PHA PHO PMB PUN)
startyear=1850
startmonth=01
endyear=3011
runtype="'HISTORY'"
outdir=/projectnb/dietzelab/paleon/ED_runs/phase1a_runs.v3/
cpdir=/projectnb/dietzelab/paleon/ED_runs/phase1a_spinfinish.v3/

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
    cp ${cpdir}$SITE/paleon_ed2_smp_geo.sh ${outdir}/$SITE/
    cp ${cpdir}$SITE/PL_MET_HEADER ${outdir}/$SITE/
    cp ${cpdir}$SITE/PalEON_Phase1a.v3.xml ${outdir}/$SITE/
    mkdir ${outdir}$SITE/histo
    mkdir ${outdir}$SITE/analy
    
	#edit ED2IN file with correct params & path
    pushd ${outdir}$SITE/
    ln -s /usr2/postdoc/crolli/ED2/ED/build/ed_2.1-opt .
    newbase=${outdir}$SITE
    oldbase=${cpdir}$SITE

    sed -i "s,$oldbase.*,$newbase,g" paleon_ed2_geo.sh #change path in submit script
    sed -i "s,${SITE},${SITE}${rep},g" paleon_ed2_geo.sh #change job name
    popd
done






