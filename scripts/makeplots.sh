#!/bin/bash 
make_line
echo "Creating output files"
make_line


cd $BASE_PATH/${release_L1}/src/HcalTrigger/Validation/scripts
eval `scram runtime -sh`

rates.exe def ./hcal_${run}_def/
rates.exe new ./hcal_${run}_new_cond/
mkdir plots
draw_rates.exe
ls plots
if [[ $local_out == "true" ]]; then
    mkdir ${outdir}/${NewLUTtag}/L1Plots
else
    eos mkdir ${outdir}/${NewLUTtag}/L1Plots
fi
xrdcp -rf plots ${outdir}/${NewLUTtag}/L1Plots
