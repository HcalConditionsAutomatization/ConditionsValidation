#!/bin/bash
# Script to generate cmsRun python configuration file
# usage: ./ntuple_maker_template default 1 1000 Run2_2018 101X_dataRun2_HLT_v7 /store/data/Run2018D/ZeroBias/RAW/v1/000/325/170/00000/FF9E45DF-DC15-E749-8E0C-0EE9A37361CD.root

if [ "$1" == "default" ]; then
  cmsDriver.py l1Ntuple -s RAW2DIGI \
  --python_filename="ntuple_maker_def_$2.py" \
  -n $3 --no_output \
  --era=$4 --data \
  --conditions="$5" \
  --customise=L1Trigger/Configuration/customiseReEmul.L1TReEmulFromRAWsimHcalTP \
  --customise=L1Trigger/L1TNtuples/customiseL1Ntuple.L1NtupleRAWEMU \
  --customise=L1Trigger/Configuration/customiseSettings.L1TSettingsToCaloParams_2018_v1_4 \
  --customise_commands='process.HcalTPGCoderULUT.LUTGenerationMode=cms.bool(False)' \
  --filein=$6 \
  --fileout=L1Ntuple_$2.root \
  --no_exec
  exit 0
elif [ "$1" == "new_con" ]; then
  cmsDriver.py l1Ntuple -s RAW2DIGI \
  --python_filename="ntuple_maker_new_$2.py" \
  -n $3 --no_output \
  --era=$4 --data \
  --conditions="$5" \
  --customise=L1Trigger/Configuration/customiseReEmul.L1TReEmulFromRAWsimHcalTP \
  --customise=L1Trigger/L1TNtuples/customiseL1Ntuple.L1NtupleRAWEMU \
  --customise=L1Trigger/Configuration/customiseSettings.L1TSettingsToCaloParams_2018_v1_4 \
  --custom_conditions=Tag,HcalL1TriggerObjectsRcd,sqlite_file:../HcalL1TriggerObjects.db \
  --customise_commands='process.HcalTPGCoderULUT.LUTGenerationMode=cms.bool(False)' \
  --filein=$6 \
  --fileout=L1Ntuple_$2.root \
  --no_exec 
  exit 0
else
  exit -1
fi
