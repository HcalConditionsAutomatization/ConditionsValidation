#!/bin/bash

file="NewValidation.txt"
validate=`grep "validate" $file | awk '{print $2}'`
if [ $validate = "yes" ]; 
then

export year=`grep "year" $file | awk '{print $2}'`
export week=`grep "week" $file | awk '{print $2}'`

export NewLUTtag=`grep "NewLUTtag" $file | awk '{print $2}'`
export NewGT=`grep "NewGT" $file | awk '{print $2}'`
export NewRun=`grep "NewRun" $file | awk '{print $2}'`
export lumi_start=`grep "lumi_start" $file | awk '{print $2}'`
export lumi_end=`grep "lumi_end" $file | awk '{print $2}'`

export OldLUTtag=`grep "OldLUTtag" $file | awk '{print $2}'`
export OldGT=`grep "OldGT" $file | awk '{print $2}'`
export OldRun=`grep "OldRun" $file | awk '{print $2}'`

export L1TOtag=`grep "L1TOtag" $file | awk '{print $2}'`
export geometry=`grep "geometry" $file | awk '{print $2}'`

export dataset=`grep "dataset" $file | awk '{print $2}'`
export tier2=`grep "tier2" $file | awk '{print $2}'`

export release_LUT=`grep "release_LUT" $file | awk '{print $2}'`
export arch_LUT=`grep "arch_LUT" $file | awk '{print $2}'`
export release_L1=`grep "release_L1" $file | awk '{print $2}'`
export arch_L1=`grep "arch_L1" $file | awk '{print $2}'`


> lumimask.json
echo {'"'${NewRun}'"': [[$lumi_start, $lumi_end]]} > lumimask.json

###L1T###
./runL1THcalConditionValidation.sh 

cp $file RunFiles/Validation_${year}_${week}.txt
#cp RunFiles/DefaultValidation.txt NewValidation.txt
sed -ie 's/validate yes/validate no/' $file
git add RunFiles/Validation_${year}_${week}.txt
git commit -a -m "clean validation inputs"
git push -u origin HEAD:master


else
echo "Not validate"
fi
