#!/bin/bash


make_line 
echo "LUT generation and validation"
make_line

cd $BASE_PATH
export LOGFILE=$LOG_DIR/lutgen.log

{

echo scram -a $arch_LUT project $release_LUT
scram -a $arch_LUT project $release_LUT

cd $release_LUT/src

echo "Evaluating $(scram runtime -sh)"
eval `scram runtime -sh`


base_dir="$(pwd)"

echo "Successfully setup environment, now merging"

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
cp -f $BASE_PATH/ConditionsValidation/LUTFigureParameters/PlotLUT.py PlotLUT.py
cp -f $BASE_PATH/ConditionsValidation/LUTFigureParameters/HcalLutAnalyzer.cc ../plugins/HcalLutAnalyzer.cc
sed -n '34,35p' $BASE_PATH/ConditionsValidation/LUTFigureParameters/PlotLUT.py
sed -n '141p' $BASE_PATH/ConditionsValidation/LUTFigureParameters/HcalLutAnalyzer.cc
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

cp $BASE_PATH/ConditionsValidation/Tools/test.py .
python test.py ${NewLUTtag} ${OldLUTtag}
make_line 
ls $OUTDIR
echo conditions/${NewLUTtag}
xrdcp -rf conditions/${NewLUTtag} $OUTDIR
} >> $LOGFILE 2>&1

make_line 
echo "Copying lutgen log file"
make_line
xrdcp -rf $LOGFILE $transferdir
xrdcp -rf conditions/${NewLUTtag} $transferdir
