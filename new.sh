#!/bin/bash

file="NewValidation.txt"
validate=`grep "validate" $file | awk '{print $2}'`
if [ $validate = "yes" ]; 
then

echo $file
export year=`grep "year" $file | awk '{print $2}'`
export week=`grep "week" $file | awk '{print $2}'`
export run=`grep "run" $file | awk '{print $2}'`

###L1T###
./runL1THcalConditionValidation.sh 

mv $file RunFiles/Validation_${year}_${week}.txt
cp RunFiles/DefaultValidation.txt NewValidation.txt
git add RunFiles/Validation_${year}_${week}.txt
git commit -a -m "clean ToRun files"
git push -u origin HEAD:master


else
echo "Not validate"
fi
