#!/bin/bash -ex 

cd ..
export CMSREL=CMSSW_10_4_0_pre1
export SCRAM_ARCH=slc6_amd64_gcc700
scram -a $SCRAM_ARCH project $CMSREL
cd CMSSW_10_4_0_pre1/src
eval `scram runtime -sh`
git cms-init
git cms-addpkg CaloOnlineTools/HcalOnlineDb
scram b -j 16
scram b -j 16
cd CaloOnlineTools/HcalOnlineDb/test
cp ../../../../../HcalConditionsValidation/test.py .
python test.py

echo "Create the tag"

cd ../../../../..
export CMSREL=CMSSW_10_2_1
export SCRAM_ARCH=slc6_amd64_gcc700
scram -a $SCRAM_ARCH project $CMSREL
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
./submit_jobs.py -l ../../../../../HcalConditionsValidation/lumimask.json -d /ZeroBias/Run2018D-v1/RAW -t HcalL1TriggerObjects_2018_v15.0_data -o T2_BR_SPRACE

