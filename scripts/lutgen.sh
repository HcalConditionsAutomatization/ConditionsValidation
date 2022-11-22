#!/bin/bash


make_line 
echo " LUT generation and validation"
make_line

cd $BASE_PATH

scram -a $arch_LUT project $release_LUT
cd $release_LUT/src
eval `scram runtime -sh`

base_dir="$(pwd)"

git cms-addpkg CaloOnlineTools/HcalOnlineDb
git cms-merge-topic -u akhukhun:xmldbformat
if [[ ! -z "$zdc_lut_topic" ]]; then
    echo "Merging topic $zdc_lut_topic"
    git cms-merge-topic -u "$zdc_lut_topic"
else
    echo "No zdc_lut_topic provided, proceeding as is."
fi

sed -i "s/const std::map<int, std::shared_ptr<LutXml> > _zdc_lut_xml = getZdcLutXml( _tag, split_by_crate );/\/\/const std::map<int, std::shared_ptr<LutXml> > _zdc_lut_xml = getZdcLutXml( _tag, split_by_crate );/" 'CaloOnlineTools/HcalOnlineDb/src/HcalLutManager.cc'
sed -i "s/addLutMap( xml, _zdc_lut_xml );/\/\/addLutMap( xml, _zdc_lut_xml );/" 'CaloOnlineTools/HcalOnlineDb/src/HcalLutManager.cc'

scram b

cd CaloOnlineTools/HcalOnlineDb/test/
# changing the plotting parameters to zoom in on changes
echo "copying the new plotting parameters"
cp -f ../../../../../ConditionsValidation/LUTFigureParameters/PlotLUT.py PlotLUT.py
cp -f ../../../../../ConditionsValidation/LUTFigureParameters/HcalLutAnalyzer.cc ../plugins/HcalLutAnalyzer.cc
sed -n '34,35p' ../../../../../ConditionsValidation/LUTFigureParameters/PlotLUT.py
sed -n '141p' ../../../../../ConditionsValidation/LUTFigureParameters/HcalLutAnalyzer.cc
echo "finished copying the plotting parameters"
sed -n '34,35p' PlotLUT.py
sed -n '141p' ../plugins/HcalLutAnalyzer.cc
cd ../plugins
scram b clean
scram b
cd ../test

> cardPhysics.sh
echo GlobalTag=$NewGT >> cardPhysics.sh
echo Tag=$NewLUTtag >> cardPhysics.sh
echo Run=$NewRun >> cardPhysics.sh
echo OldTag=$OldLUTtag >> cardPhysics.sh
echo OldRun=$OldRun >> cardPhysics.sh
echo description='"validation"' >> cardPhysics.sh
echo HOAsciiInput=$HOAsciiInput >> cardPhysics.sh
echo O2OL1TriggerObjects=false >> cardPhysics.sh
echo O2OInputs=false >> cardPhysics.sh

> cardPhysics_gen_old.sh
echo GlobalTag=$OldGT >> cardPhysics_gen_old.sh
echo Tag=$OldLUTtag >> cardPhysics_gen_old.sh
echo Run=$OldRun >> cardPhysics_gen_old.sh
echo description='"validation"' >> cardPhysics_gen_old.sh
echo HOAsciiInput=$HOAsciiInput >> cardPhysics_gen_old.sh
echo O2OL1TriggerObjects=false >> cardPhysics_gen_old.sh
echo O2OInputs=false >> cardPhysics_gen_old.sh

echo 'cp ../../../../../ConditionsValidation/Tools/test.py .'
cp $BASE_PATH/ConditionsValidation/Tools/test.py .
#python test.py $NewRun $NewLUTtag $NewGT $OldRun $OldLUTtag $OldGT
python test.py ${NewLUTtag} ${OldLUTtag}
echo "os ls $OUTDIR"
make_line 
#if [[ $local_out == "true" ]]; then
#if [[ ! -d ${OUTDIR} ]]; then
#    mkdir $OUTDIR
#fi
mkdir -p $OUTDIR
ls $OUTDIR
echo conditions/${NewLUTtag}
#else
#    eos ls $OUTDIR
#    echo conditions/${NewLUTtag}
#    eos mkdir $outdir/${NewLUTtag}
#fi
xrdcp -rf conditions/${NewLUTtag} $OUTDIR
