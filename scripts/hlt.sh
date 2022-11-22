#!/usr/bin/env bash


make_line
echo "Running HLT Validation"
make_line 

cd $BASE_PATH

echo "Constructing environment"
scram -a $arch_HLT project $release_HLT
cd $release_HLT/src
eval `scram runtime -sh`

echo "Creating hlt configuration"
hltGetConfiguration run:$run \
    --globaltag $OldGT \
    --data \
    --unprescale \
    --output minimal \
    --max-events $hlt_max_events \
    --input "$hlt_dataset" \
    --path "$hlt_paths" \
    > hltReference.py

echo "process.schedule.remove(process.DQMHistograms)" >> hltReference.py
echo "process.options.numberOfThreads = 16" >> hltReference.py
cp hltReference.py hltTarget.py
echo "process.GlobalTag.globaltag = '$NewGT'" >> hltTarget.py
echo "process.hltOutputMinimal.fileName = 'outputTarget.root'" >> hltTarget.py
rm output.root outputTarget.root

cmsRun hltReference.py >& logRef &
sleep 5
cmsRun hltTarget.py >& logTar
wait
hltDiff -o output.root -n outputTarget.root

