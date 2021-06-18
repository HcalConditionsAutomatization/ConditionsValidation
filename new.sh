#!/bin/bash

file="_NewValidation.txt"
sed 's/^#.*$//g' "NewValidation.txt" > $file
validate=`grep "validate" $file | awk '{print $2}'`
if [ $validate = "yes" ];
then

export year=`grep "year" $file | awk '{print $2}'`
export week=`grep "week" $file | awk '{print $2}'`

export NewLUTtag=`grep "NewLUTtag" $file | awk '{print $2}'`
export NewGT=`grep "NewGT" $file | awk '{print $2}'`
export NewRun=`grep "NewRun" $file | awk '{print $2}'`
export NewGains=`grep "NewGains" $file | awk '{print $2}'`

export OldLUTtag=`grep "OldLUTtag" $file | awk '{print $2}'`
export OldGT=`grep "OldGT" $file | awk '{print $2}'`
export OldRun=`grep "OldRun" $file | awk '{print $2}'`

export HOAsciiInput=`grep "HOAsciiInput" $file | awk '{print $2}'`

export geometry=`grep "geometry" $file | awk '{print $2}'`

export run=`grep "run" $file | awk '{print $2}'`
export lumimask=`grep "lumimask" $file | awk '{print $2}'`
export lumiblock=`grep "lumiblock" $file | awk '{print $2}'`
export dataset=`grep "dataset" $file | awk '{print $2}'`
export tier2=`grep "tier2" $file | awk '{print $2}'`
export outdir=`grep "outdir" $file | awk '{print $2}'`

export release_LUT=`grep "release_LUT" $file | awk '{print $2}'`
export arch_LUT=`grep "arch_LUT" $file | awk '{print $2}'`
export release_L1=`grep "release_L1" $file | awk '{print $2}'`
export arch_L1=`grep "arch_L1" $file | awk '{print $2}'`
export version_L1=`grep "version_L1" $file | awk '{print $2}'`
export nEvts=`grep "nEvts" $file | awk '{print $2}'`
export max_file_num=`grep "max_file_num" $file | awk '{print $2}'`


###L1T###

chmod +x runL1THcalConditionValidation.sh
./runL1THcalConditionValidation.sh
cp $file RunFiles/Validation_${year}_${week}.txt
sed -i 's/yes/no/' $file
git add RunFiles/Validation_${year}_${week}.txt
git commit -a -m "clean validation inputs"
git push -u origin HEAD:master

else
  echo "Not validate"
fi
