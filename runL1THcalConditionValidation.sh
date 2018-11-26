#!/bin/bash 

sleep 5
 
###############################
testMenu=/cdaq/physics/Run2018/2e34/v2.0.1/HLT/V1
#GT=101X_dataRun2_HLT_v7
GT=101X_dataRun2_HLT_SiPixelQualityv9_v1
reference=$1
listaFiles=files_Run_316058.txt
sqlite=DBLaser_${2}_moved_to_1
sqlitePED=Pedes_${2}
sqlitePULSE=ecaltemplates_popcon_run_${2}
sqliteTIME=ecaltimingic_popcon_run_${2}
pathToMonitor=("HLT_Ele32_WPTight_Gsf_v" "HLT_Ele35_WPTight_Gsf_v" "HLT_Ele35_WPTight_Gsf_L1EGMT_v" "HLT_Ele38_WPTight_Gsf_v" "HLT_Ele30_eta2p1_WPTight_Gsf_CentralPFJet35_EleCleaned_v" "HLT_Photon33_v" "HLT_PFMET120_PFMHT120_IDTight_v" "HLT_PFMET100_PFMHT100_IDTight_PFHT60_v" "HLT_PFMETTypeOne120_PFMHT120_IDTight_v" )
maxEvents=100000
###############################


export CMSREL=CMSSW_10_1_4
export SCRAM_ARCH=slc6_amd64_gcc630
#scram -a $SCRAM_ARCH project $CMSREL
#cp $listaFiles $CMSREL/src/
#cd $CMSREL/src
#eval `scram runtime -sh`
echo $CMSREL
echo $1
echo $2
echo $3
echo $4
echo $5

