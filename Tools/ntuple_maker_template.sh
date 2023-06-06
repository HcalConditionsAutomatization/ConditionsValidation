#!/bin/bash
# Script to generate cmsRun python configuration file
# usage: ./ntuple_maker_template default 1 1000 Run2_2018 101X_dataRun2_HLT_v7 /store/data/Run2018D/ZeroBias/RAW/v1/000/325/170/00000/FF9E45DF-DC15-E749-8E0C-0EE9A37361CD.root ./lumimask.txt

if [ "$1" == "default" ]; then
  cmsDriver.py l1Ntuple -s RAW2DIGI \
  --python_filename="ntuple_maker_def_$2.py" \
  -n $3 --no_output \
  --era=$4 --data \
  --conditions="$5" \
  --customise=L1Trigger/Configuration/customiseReEmul.L1TReEmulFromRAWsimHcalTP \
  --customise=L1Trigger/L1TNtuples/customiseL1Ntuple.L1NtupleRAWEMU \
  --customise="$8" \
  --customise_commands='process.HcalTPGCoderULUT.LUTGenerationMode=cms.bool(False)' \
  --filein=$6 \
  --fileout=L1Ntuple_$2.root \
  --no_exec
#https://twiki.cern.ch/twiki/bin/view/CMSPublic/SWGuideGoodLumiSectionsJSONFile, to add lumi mask application
  sed -i '/import FWCore.ParameterSet.Config as cms/a import FWCore.PythonUtilities.LumiList as LumiList' "ntuple_maker_def_$2.py"
  sed -i "/secondaryFileNames = cms.untracked.vstring()/{N;
  a process.source.lumisToProcess = LumiList.LumiList(filename ='$7').getVLuminosityBlockRange()
  }" "ntuple_maker_def_$2.py"
  exit 0
elif [ "$1" == "new_con" ]; then
  cmsDriver.py l1Ntuple -s RAW2DIGI \
  --python_filename="ntuple_maker_new_$2.py" \
  -n $3 --no_output \
  --era=$4 --data \
  --conditions="$5" \
  --customise=L1Trigger/Configuration/customiseReEmul.L1TReEmulFromRAWsimHcalTP \
  --customise=L1Trigger/L1TNtuples/customiseL1Ntuple.L1NtupleRAWEMU \
  --customise="$8" \
  --custom_conditions=Tag,HcalL1TriggerObjectsRcd,sqlite_file:../HcalL1TriggerObjects.db \
  --customise_commands='process.HcalTPGCoderULUT.LUTGenerationMode=cms.bool(False)' \
  --filein=$6 \
  --fileout=L1Ntuple_$2.root \
  --no_exec 
#https://twiki.cern.ch/twiki/bin/view/CMSPublic/SWGuideGoodLumiSectionsJSONFile, to add lumi mask application
  sed -i '/import FWCore.ParameterSet.Config as cms/a import FWCore.PythonUtilities.LumiList as LumiList' "ntuple_maker_new_$2.py"
  sed -i "/secondaryFileNames = cms.untracked.vstring()/{N;
  a process.source.lumisToProcess = LumiList.LumiList(filename ='$7').getVLuminosityBlockRange()
  }" "ntuple_maker_new_$2.py"
  exit 0
else
  exit -1
fi
