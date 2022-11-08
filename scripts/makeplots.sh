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
#    mkdir ${outdir}/${NewLUTtag}/L1Plots
    mkdir $OUTDIR/rates
else
#    eos mkdir ${outdir}/${NewLUTtag}/L1Plots
    eos mkdir $OUTDIR/rates
fi
xrdcp -rf rates_def.root $OUTDIR/rates/
xrdcp -rf rates_new_cond.root $OUTDIR/rates/
xrdcp -rf plots $OUTDIR
