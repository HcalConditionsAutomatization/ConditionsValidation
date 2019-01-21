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

export OldLUTtag=`grep "OldLUTtag" $file | awk '{print $2}'`
export OldGT=`grep "OldGT" $file | awk '{print $2}'`
export OldRun=`grep "OldRun" $file | awk '{print $2}'`

export HOAsciiInput=`grep "HOAsciiInput" $file | awk '{print $2}'`

export geometry=`grep "geometry" $file | awk '{print $2}'`

export run=`grep "run" $file | awk '{print $2}'`
export lumi_start=`grep "lumi_start" $file | awk '{print $2}'`
export lumi_end=`grep "lumi_end" $file | awk '{print $2}'`
export dataset=`grep "dataset" $file | awk '{print $2}'`
export tier2=`grep "tier2" $file | awk '{print $2}'`
export outdir=`grep "outdir" $file | awk '{print $2}'`

export release_LUT=`grep "release_LUT" $file | awk '{print $2}'`
export arch_LUT=`grep "arch_LUT" $file | awk '{print $2}'`
export release_L1=`grep "release_L1" $file | awk '{print $2}'`
export arch_L1=`grep "arch_L1" $file | awk '{print $2}'`


###L1T###
./runL1THcalConditionValidation.sh 

cp $file RunFiles/Validation_${year}_${week}.txt
sed -i 's/yes/no/' $file
sed -i "s:const std::map<int, std::shared_ptr<LutXml> > _zdc_lut_xml = getZdcLutXml( _tag, split_by_crate );://const std::map<int, std::shared_ptr<LutXml> > _zdc_lut_xml = getZdcLutXml( _tag, split_by_crate );:" 'HcalLutManager.cc'
git add RunFiles/Validation_${year}_${week}.txt
git commit -a -m "clean validation inputs"
git push -u origin HEAD:master


else
echo "Not validate"
fi
