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
echo "HOAsciiInput " $HOAsciiInput
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
echo " "
echo "======================================================================================================================"
echo " LUT generation and validation"
echo "======================================================================================================================"
cd ..
scram -a $arch_LUT project $release_LUT
cd CMSSW_10_4_0_pre1/src
eval `scram runtime -sh`
git cms-merge-topic -u akhukhun:xmldbformat
sed -i "s/const std::map<int, std::shared_ptr<LutXml> > _zdc_lut_xml = getZdcLutXml( _tag, split_by_crate );/\/\/const std::map<int, std::shared_ptr<LutXml> > _zdc_lut_xml = getZdcLutXml( _tag, split_by_crate );/" 'CaloOnlineTools/HcalOnlineDb/src/HcalLutManager.cc'
sed -i "s/addLutMap( xml, _zdc_lut_xml );/\/\/addLutMap( xml, _zdc_lut_xml );/" 'CaloOnlineTools/HcalOnlineDb/src/HcalLutManager.cc'
scram b
cd CaloOnlineTools/HcalOnlineDb/test/

> cardPhysics.sh
echo GlobalTag=$NewGT >> cardPhysics.sh
echo Tag=$NewLUTtag >> cardPhysics.sh
echo Run=$NewRun >> cardPhysics.sh
echo OldTag=$OldLUTtag >> cardPhysics.sh
echo OldRun=$OldRun >> cardPhysics.sh
echo description='"validation"' >> cardPhysics.sh
echo HOAsciiInput=$HOAsciiInput >> cardPhysics.sh
echo O2OL1TriggerObjects=false >> cardPhysics.sh
echo O2OInputs=false >> cardPhysics.sh

> cardPhysics_gen_old.sh
echo GlobalTag=$OldGT >> cardPhysics_gen_old.sh
echo Tag=$OldLUTtag >> cardPhysics_gen_old.sh
echo Run=$OldRun >> cardPhysics_gen_old.sh
echo description='"validation"' >> cardPhysics_gen_old.sh
echo HOAsciiInput=$HOAsciiInput >> cardPhysics_gen_old.sh
echo O2OL1TriggerObjects=false >> cardPhysics_gen_old.sh
echo O2OInputs=false >> cardPhysics_gen_old.sh

cp ../../../../../HcalConditionsValidation/Tools/test.py .
python test.py $NewRun $NewLUTtag $NewGT $OldRun $OldLUTtag $OldGT   
cp -r conditions/${NewLUTtag} $outdir
 
echo " "
echo "======================================================================================================================"
echo " L1TriggerObjects Tag generation"
echo "======================================================================================================================"
cp conditions/$NewLUTtag/Deploy/Gen_L1TriggerObjects_${NewLUTtag}.txt ../../..
cd ../../..
cp ../../HcalConditionsValidation/Tools/writetoSQL9x.csh .
chmod +x writetoSQL9x.csh
./writetoSQL9x.csh $geometry L1TriggerObjects Gen_L1TriggerObjects_${NewLUTtag}.txt Tag 1 HcalL1TriggerObjects.db
cp HcalL1TriggerObjects.db ${outdir}/${NewLUTtag}

echo " "
echo "====================================================================================================================="
echo " L1 rate validation"
echo "====================================================================================================================="
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
scram b -j 8

#cd CMSSW_10_3_1/src
#eval `scram runtime -sh`
#git cms-init
#git remote add cms-l1t-offline git@github.com:cms-l1t-offline/cmssw.git
#git fetch cms-l1t-offline l1t-integration-CMSSW_10_3_1
#git cms-merge-topic -u cms-l1t-offline:l1t-integration-v102.1-CMSSW_10_3_1
#git cms-addpkg L1Trigger/L1TCommon
#git cms-addpkg L1Trigger/L1TMuon
#git clone https://github.com/cms-l1t-offline/L1Trigger-L1TMuon.git L1Trigger/L1TMuon/data
#git cms-addpkg L1Trigger/L1TCalorimeter
#git clone https://github.com/cms-l1t-offline/L1Trigger-L1TCalorimeter.git L1Trigger/L1TCalorimeter/data
#scram b -j 8
#----------------------------------------------------------------------------------------------------
git clone git@github.com:cms-hcal-trigger/Validation.git HcalTrigger/Validation
scram b -j 8
cd HcalTrigger/Validation/scripts
cp ../../../../../HcalConditionsValidation/Tools/submit_jobs.py .

> lumimask.json
echo {'"'${run}'"': [[$lumi_start, $lumi_end]]} > lumimask.json

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





















