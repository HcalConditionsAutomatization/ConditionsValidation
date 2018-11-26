#!/bin/bash

file="NewValidation.txt"
validate=`grep "validate" $file | awk '{print $2}'`
if [ $validate = "yes" ]; 
then

echo $file
year=`grep "year" $file | awk '{print $2}'`
week=`grep "week" $file | awk '{print $2}'`
sqliteRef=`grep "run1" $file | awk '{print $2}'`
sqliteNew=`grep "run2" $file | awk '{print $2}'`
label=`grep "type" $file | awk '{print $2}'`


###L1T###
echo "./runL1THcalConditionValidation.sh $sqliteRef $sqliteNew $label $week $year"
./runL1THcalConditionValidation.sh $sqliteRef $sqliteNew $label $week $year

mv $file RunFiles/Validation_${year}_${week}.txt
cp RunFiles/DefaultValidation.txt NewValidation.txt
git add RunFiles/Validation_${year}_${week}.txt
git commit -a -m "clean ToRun files"
git push -u origin HEAD:master


else
echo "Not validate"
fi
