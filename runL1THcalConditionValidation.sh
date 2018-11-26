#!/bin/bash 

cd ..
cmsrel CMSSW_10_4_0_pre1
cd CMSSW_10_4_0_pre1/src
cmsenv
git cms-addpkg CaloOnlineTools/HcalOnlineDb
scram b -j 16
cd CaloOnlineTools/HcalOnlineDb/test
cp /afs/cern.ch/user/c/cawest/public/forGilson/test.py .
python test.py