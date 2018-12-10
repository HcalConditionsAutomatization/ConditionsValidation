#!/bin/bash 

echo "==============================================="
echo "week         " $week
echo "year         " $year
echo "NewLUTtag    " $NewLUTtag
echo "NewGT        " $NewGT
echo "NewRun       " $NewRun
echo "OldLUTtag    " $OldLUTtag
echo "OldGT        " $OldGT
echo "OldRun       " $OldRun
echo "geometry     " $geometry
echo "run          " $run
echo "lumi_section " [$lumi_start,$lumi_end]
echo "dataset      " $dataset
echo "tier2        " $tier2
echo "release_LUT  " $release_LUT
echo "arch_LUT     " $arch_LUT
echo "release_L1   " $release_L1
echo "arch_L1      " $arch_L1
echo "==============================================="

#======================================================================================================================
# LUT generation and validation
#======================================================================================================================
cd ..
scram -a $arch_LUT project $release_LUT
cd CMSSW_10_4_0_pre1/src
eval `scram runtime -sh`
git cms-init
git cms-addpkg CaloOnlineTools/HcalOnlineDb
scram b -j 16
scram b -j 16
cd CaloOnlineTools/HcalOnlineDb/test
cp ../../../../../HcalConditionsValidation/test.py .
python test.py $NewRun $NewLUTtag $NewGT $OldRun $OldLUTtag $OldGT   
#./genLUT.sh dumpAll card=cardPhysics.sh
#./genLUT.sh generate card=cardPhysics.sh
#./genLUT.sh dumpAll card=cardPhysics.sh
#./genLUT.sh generate card=cardPhysics.sh
#./genLUT.sh validate card=cardPhysics.sh


#======================================================================================================================
# L1TriggerObjects Tag generation
#======================================================================================================================
cp conditions/$NewLUTtag/Deploy/Gen_L1TriggerObjects_${NewLUTtag}.txt ../../..
#copy conditions to output directory
cd ../../..
cp ../../HcalConditionsValidation/writetoSQL9x.csh .
chmod +x writetoSQL9x.csh
./writetoSQL9x.csh $geometry L1TriggerObjects Gen_L1TriggerObjects_${NewLUTtag}.txt Tag 1 HcalL1TriggerObjects.db
#copy sqlfile to output directory


#=====================================================================================================================
# L1 rate validation
#=====================================================================================================================
cd ../..
scram -a $arch_L1 project $release_L1
cd CMSSW_10_2_1/src
eval `scram runtime -sh`
git cms-init
git remote add cms-l1t-offline git@github.com:cms-l1t-offline/cmssw.git
git fetch cms-l1t-offline l1t-integration-CMSSW_10_2_1
git cms-merge-topic -u cms-l1t-offline:l1t-integration-v101.0
git cms-addpkg L1Trigger/L1TCommon
git cms-addpkg L1Trigger/L1TMuon
git clone https://github.com/cms-l1t-offline/L1Trigger-L1TMuon.git L1Trigger/L1TMuon/data
git cms-addpkg L1Trigger/L1TCalorimeter
git clone https://github.com/cms-l1t-offline/L1Trigger-L1TCalorimeter.git L1Trigger/L1TCalorimeter/data
git clone git@github.com:cms-hcal-trigger/Validation.git HcalTrigger/Validation
scram b -j 16
scram b -j 16
cd HcalTrigger/Validation/scripts
cp ../../../../../HcalConditionsValidation/submit_jobs.py .
cp ../../../../../HcalConditionsValidation/lumimask.json .
cp ../../../../../CMSSW_10_4_0_pre1/src/HcalL1TriggerObjects.db .
./submit_jobs.py -l lumimask.json -d $dataset -t Tag -o $tier2
sed -i '/config.JobType.outputFiles/ i\config.JobType.inputFiles = ["HcalL1TriggerObjects.db"]' submit_new_cond.py
crab submit -c submit_new_cond.py
