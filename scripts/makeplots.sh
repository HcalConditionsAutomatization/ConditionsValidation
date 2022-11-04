#!/bin/bash 
make_line
echo "Creating output files"
make_line

cd $BASE_PATH/${release_L1}/src/HcalTrigger/Validation/scripts
scram b -j 8

$BASE_PATH/${release_L1}/bin/slc7_amd64_gcc900/rates.exe def ./hcal_${run}_def/
$BASE_PATH/${release_L1}/bin/slc7_amd64_gcc900/rates.exe new ./hcal_${run}_new_cond/
mkdir plots
$BASE_PATH/${release_L1}/bin/slc7_amd64_gcc900/draw_rates.exe
ls plots
if [[ $local_out == "true" ]]; then
    mkdir ${outdir}/${NewLUTtag}/L1Plots
else
    eos mkdir ${outdir}/${NewLUTtag}/L1Plots
fi
xrdcp -rf plots ${outdir}/${NewLUTtag}/L1Plots
