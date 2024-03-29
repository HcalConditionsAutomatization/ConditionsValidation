#!/bin/bash

file="configuration/_NewValidation.txt"
sed 's/^#.*$//g' "configuration/NewValidation.txt" > $file
validate=`grep "validate" $file | awk '{print $2}'`
if [ $validate = "yes" ];
then

export HOAsciiInput=`grep "^HOAsciiInput" $file | awk '{print $2}'`
export release_L1=`grep "^release_L1" $file | awk '{print $2}'`
export NewLUTtag=`grep "^NewLUTtag" $file | awk '{print $2}'`
export NewGT=`grep "^NewGT" $file | awk '{print $2}'`
export dataset=`grep "^dataset" $file | awk '{print $2}'`
export year=`grep "^year" $file | awk '{print $2}'`
export nEvts=`grep "^nEvts" $file | awk '{print $2}'`
export lumi_start=`grep "^lumi_start" $file | awk '{print $2}'`
export tier2=`grep "^tier2" $file | awk '{print $2}'`
export OldRun=`grep "^OldRun" $file | awk '{print $2}'`
export lumi_end=`grep "^lumi_end" $file | awk '{print $2}'`
export version_L1=`grep "^version_L1" $file | awk '{print $2}'`
export OldLUTtag=`grep "^OldLUTtag" $file | awk '{print $2}'`
export week=`grep "^week" $file | awk '{print $2}'`
export run=`grep "^run" $file | awk '{print $2}'`
export max_file_num=`grep "^max_file_num" $file | awk '{print $2}'`
export OldGT=`grep "^OldGT" $file | awk '{print $2}'`
export NewRun=`grep "^NewRun" $file | awk '{print $2}'`
export release_LUT=`grep "^release_LUT" $file | awk '{print $2}'`
export outdir=`grep "^outdir" $file | awk '{print $2}'`
export transferdir=`grep "^transferdir" $file | awk '{print $2}'`
export local_out=`grep "^local_out" $file | awk '{print $2}'`
export geometry=`grep "^geometry" $file | awk '{print $2}'`
export arch_L1=`grep "^arch_L1" $file | awk '{print $2}'`
export arch_LUT=`grep "^arch_LUT" $file | awk '{print $2}'`
export zdc_lut_topic=`grep "^zdc_lut_topic" $file | awk '{print $2}'`
export calo_params=`grep "^calo_params" $file | awk '{print $2}'`
export hlt_dataset=`grep "^hlt_dataset" $file | awk '{print $2}'`
export hlt_paths=`grep "^hlt_paths" $file | awk '{print $2}'`
export release_HLT=`grep "^release_HLT" $file | awk '{print $2}'`
export arch_HLT=`grep "^arch_HLT" $file | awk '{print $2}'`
export hlt_max_events=`grep "^hlt_max_events" $file | awk '{print $2}'`

###L1T###

chmod +x runHcalConditionValidation.sh
./runHcalConditionValidation.sh
if [[ "$local_out" == "false" ]]; then
    cp $file RunFiles/Validation_${year}_${week}.txt
    sed -i 's/yes/no/' $file
    #git add RunFiles/Validation_${year}_${week}.txt
    #git commit -a -m "clean validation inputs"
    #git push -u origin HEAD:master
fi

else
  echo "Not validate"
fi
