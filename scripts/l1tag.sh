#!/bin/bash

make_line
echo " L1TriggerObjects Tag generation"
make_line

cd "$BASE_PATH/${release_LUT}/src/CaloOnlineTools/HcalOnlineDb/test/"

export LOGFILE=$LOG_DIR/l1tag.log

{
eval `scram runtime -sh`


ls conditions/$NewLUTtag/Deploy/
cp conditions/$NewLUTtag/Deploy/Gen_L1TriggerObjects_${NewLUTtag}.txt ../../..
cd ../../..
cp ../../ConditionsValidation/Tools/writetoSQL.csh .
chmod +x writetoSQL.csh
./writetoSQL.csh 2023 L1TriggerObjects Gen_L1TriggerObjects_${NewLUTtag}.txt Tag 1 HcalL1TriggerObjects.db
xrdcp -f HcalL1TriggerObjects.db $OUTDIR/HcalL1TriggerObjects.db
echo "eos ls $outdir"
#if [[ $local_out == "true" ]]; then
ls $OUTDIR
#else
#    eos ls $outdir/${NewLUTtag}/.
#fi
}   >> $LOGFILE 2>&1
