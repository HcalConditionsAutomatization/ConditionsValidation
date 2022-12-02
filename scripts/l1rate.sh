#!/bin/bash

make_line
echo " L1 rate validation"
make_line

cd $BASE_PATH
export LOGFILE=$LOG_DIR/l1rate.log
export listFiles="listOfFiles.txt"

{
echo "scram -a $arch_L1 project $release_L1"
scram -a $arch_L1 project $release_L1

cd ${release_L1}/src

eval `scram runtime -sh`

git cms-init
git remote add cms-l1t-offline git@github.com:cms-l1t-offline/cmssw.git
git fetch -u cms-l1t-offline l1t-integration-${release_L1}
git cms-merge-topic -u cms-l1t-offline:l1t-integration-v${version_L1}
git clone https://github.com/cms-l1t-offline/L1Trigger-L1TCalorimeter.git L1Trigger/L1TCalorimeter/data
git cms-checkdeps -A -a
scram b -j 8
#----------------------------------------------------------------------------------------------------
git clone git@github.com:cms-hcal-trigger/Validation.git HcalTrigger/Validation
scram b -j 8
cd HcalTrigger/Validation/scripts

mkdir hcal_${run}_def
mkdir hcal_${run}_new_cond

cp $BASE_PATH/ConditionsValidation/Tools/ntuple_maker_template.sh ./
cp $BASE_PATH/$release_LUT/src/HcalL1TriggerObjects.db .
cp $BASE_PATH/$release_LUT/src/HcalL1TriggerObjects.db ./hcal_${run}_def
cp $BASE_PATH/$release_LUT/src/HcalL1TriggerObjects.db ./hcal_${run}_new_cond
ls
if [[ ! $lumiblock == \#* ]]; then
  echo "{\"$run\": [[$lumi_start,$lumi_end]]}" > ./lumimask.txt
  lumimask="../../lumimask.txt"
fi

echo "Executing the following das query"
echo "dasgoclient -query=\"file dataset=${dataset} run=${run}\""
dasgoclient -query="file dataset=${dataset} run=${run}" > $listFiles
echo "Running over the following filelist"
cat $listFiles
echo "Starting jobs"
n=0
for file in `less ./${listFiles}`; do
  n=$[$n+1]
  echo "$n. $file"
  if (( "$n" <= "$max_file_num" )) || (( "$max_file_num" < 0 ))
  then
    numfolder=(`find ./hcal_${run}_def/  -maxdepth 1 -name "ntuple_maker_*" -type d | wc -l`)
    mkdir -p ./hcal_${run}_def/ntuple_maker_$numfolder && mkdir -p ./hcal_${run}_new_cond/ntuple_maker_$numfolder
    sh ./ntuple_maker_template.sh default $n $nEvts Run3 $OldGT root://cmsxrootd.fnal.gov//$file $lumimask && mv ntuple_maker_def_$n.py ./hcal_${run}_def/ntuple_maker_$numfolder
    sh ./ntuple_maker_template.sh new_con $n $nEvts Run3 $NewGT root://cmsxrootd.fnal.gov//$file $lumimask && mv ntuple_maker_new_$n.py ./hcal_${run}_new_cond/ntuple_maker_$numfolder
    ( cd ./hcal_${run}_def/ntuple_maker_$numfolder && cmsRun ntuple_maker_def_$n.py && mv L1Ntuple.root ../L1Ntuple_$n.root ) & ( cd ./hcal_${run}_new_cond/ntuple_maker_$numfolder && cmsRun ntuple_maker_new_$n.py && mv L1Ntuple.root ../L1Ntuple_$n.root ) &
#    wait
    if [ $(jobs | wc -l) -ge $jobs_in_parallel ]; then
      echo "Waiting for background processes to finish ..."
      wait
      rm -r ./hcal_${run}_def/ntuple_maker_*
      rm -r ./hcal_${run}_new_cond/ntuple_maker_*
    fi
  else
    break
  fi
done

echo "Waiting for background processes to finish ..."
wait
}   # >> $LOGFILE 2>&1
