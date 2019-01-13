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
echo "outdir       " $outdir
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
git cms-merge-topic -u akhukhun:xmldbformat
scram b
cd CaloOnlineTools/HcalOnlineDb/test/
cp ../../../../../HcalConditionsValidation/test.py .
python test.py $NewRun $NewLUTtag $NewGT $OldRun $OldLUTtag $OldGT   
#./genLUT.sh validate card=cardPhysics.sh
cp -r conditions/${NewLUTtag} $outdir
 

#======================================================================================================================
# L1TriggerObjects Tag generation
#======================================================================================================================
cp conditions/$NewLUTtag/Deploy/Gen_L1TriggerObjects_${NewLUTtag}.txt ../../..
cd ../../..
cp ../../HcalConditionsValidation/writetoSQL9x.csh .
chmod +x writetoSQL9x.csh
./writetoSQL9x.csh $geometry L1TriggerObjects Gen_L1TriggerObjects_${NewLUTtag}.txt Tag 1 HcalL1TriggerObjects.db
cp HcalL1TriggerObjects.db ${outdir}/${NewLUTtag}


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
#git cms-init
#git remote add cms-l1t-offline git@github.com:cms-l1t-offline/cmssw.git
#git fetch cms-l1t-offline l1t-integration-CMSSW_10_3_1
#git cms-merge-topic -u cms-l1t-offline:l1t-integration-v102.1-CMSSW_10_3_1
#git cms-addpkg L1Trigger/L1TCommon
#git cms-addpkg L1Trigger/L1TMuon
#git clone https://github.com/cms-l1t-offline/L1Trigger-L1TMuon.git L1Trigger/L1TMuon/data
#git cms-addpkg L1Trigger/L1TCalorimeter
#git clone https://github.com/cms-l1t-offline/L1Trigger-L1TCalorimeter.git L1Trigger/L1TCalorimeter/datascram b -j 16
git clone git@github.com:cms-hcal-trigger/Validation.git HcalTrigger/Validation
scram b -j 16
scram b -j 16
cd HcalTrigger/Validation/scripts
cp ../../../../../HcalConditionsValidation/submit_jobs.py .
cp ../../../../../HcalConditionsValidation/lumimask.json .
cp ../../../../../CMSSW_10_4_0_pre1/src/HcalL1TriggerObjects.db .
./submit_jobs.py -l lumimask.json -d $dataset -t Tag -o $tier2
sed -i '/config.JobType.outputFiles/ i\config.JobType.inputFiles = ["HcalL1TriggerObjects.db"]' submit_new_cond.py

#------------------------------------------------------------------------------------
# Submit and retrieve jobs from CRAB

crab submit submit_def.py
crab submit submit_new_cond.py 

crab status -d crab_hcal_${run}_def > status_def.log
while ! grep -q "finished" status_def.log; do
    if grep -q "failed" status_def.log; then
        crab resubmit -d crab_hcal_${run}_def
    fi
    sleep 180
    crab status -d crab_hcal_${run}_def > status_def.log
done

crab status -d crab_hcal_${run}_new_cond > status_new_cond.log
while ! grep -q "finished" status_new_cond.log; do
    if grep -q "failed" status_new_cond.log; then
        crab resubmit -d crab_hcal_${run}_new_cond
    fi
    sleep 180
    crab status -d crab_hcal_${run}_new_cond > status_new_cond.log
done

crab getoutput -d crab_hcal_${run}_def --checksum=no > retrieve_def.log
while ! grep -q "All files successfully retrieved" retrieve_def.log; do
    crab getoutput -d crab_hcal_${run}_def --checksum=no > retrieve_def.log
done

crab getoutput -d crab_hcal_${run}_new_cond --checksum=no > retrieve_new_cond.log
while ! grep -q "All files successfully retrieved" retrieve_new_cond.log; do
    crab getoutput -d crab_hcal_${run}_new_cond --checksum=no > retrieve_new_cond.log
done

#------------------------------------------------------------------------------------

rates.exe def crab_hcal_${run}_def/results
rates.exe new crab_hcal_${run}_new_cond/results
mkdir plots
draw_rates.exe
cp -r plots ${outdir}/${NewLUTtag}





















