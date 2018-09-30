#!/bin/bash -ex 

file=`ls ToRun`
echo $file
if [ -f ToRun/$file ]; 
then

echo ToRun/$file
year=`grep "year" ToRun/$file | awk '{print $2}'`
week=`grep "week" ToRun/$file | awk '{print $2}'`
sqliteRef=`grep "run1" ToRun/$file | awk '{print $2}'`
sqliteNew=`grep "run2" ToRun/$file | awk '{print $2}'`
label=`grep "type" ToRun/$file | awk '{print $2}'`

###L1T###
echo "./runL1THcalConditionValidation.sh $sqliteRef $sqliteNew $label $week $year"
./runL1THcalConditionValidation.sh $sqliteRef $sqliteNew $label $week $year

mv ToRun/$file RunFiles/Validation_${year}_${week}.txt
git add RunFiles/Validation_${year}_${week}.txt
git commit -a -m "clean ToRun files"
git push -u origin master


else
echo "No new files"
fi
