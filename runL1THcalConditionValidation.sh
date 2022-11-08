#!/bin/bash


DEFAULT_LINE_LENGTH=35
jobs_in_parallel=10
MAX_LEN=0

listFiles="listOfFiles.txt"

variables=("HOAsciiInput" "release_L1" "NewLUTtag" "NewGT" 
           "dataset" "year" "nEvts" "lumi_start" "tier2" "OldRun" 
           "lumi_end" "version_L1" "OldLUTtag" "week" "run" "max_file_num" 
           "OldGT" "NewRun" "release_LUT" "outdir" "geometry" "arch_L1" "arch_LUT" 
           "jobs_in_parallel" "calo_params" "zdc_lut_topic")

function make_line(){
    local length=${1:-$DEFAULT_LINE_LENGTH}
    head -c $length < /dev/zero | tr '\0' '='
    echo ""
}

for var in ${variables[@]}; do
    : $(( MAX_LEN = (MAX_LEN > ${#var})? MAX_LEN : ${#var}  ))
done

make_line 
for variable in ${variables[@]}; do
    printf "%-${MAX_LEN}s = %s\n" "$variable" "${!variable}"
done
make_line

make_line 
echo " LUT generation and validation"
make_line

cd ..
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
# changing the plotting parameters to zoom in on changes - only uncomment if different plotting parameters are wanted
echo "copying the new plotting parameters"
#cp -f ../../../../../ConditionsValidation/LUTFigureParameters/PlotLUT.py PlotLUT.py
#cp -f ../../../../../ConditionsValidation/LUTFigureParameters/HcalLutAnalyzer.cc ../plugins/HcalLutAnalyzer.cc
#sed -n '34,35p' ../../../../../ConditionsValidation/LUTFigureParameters/PlotLUT.py
#sed -n '141p' ../../../../../ConditionsValidation/LUTFigureParameters/HcalLutAnalyzer.cc
#echo "finished copying the plotting parameters"
#sed -n '34,35p' PlotLUT.py
#sed -n '141p' ../plugins/HcalLutAnalyzer.cc
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
cp ../../../../../ConditionsValidation/Tools/test.py .
#python test.py $NewRun $NewLUTtag $NewGT $OldRun $OldLUTtag $OldGT
python test.py ${NewLUTtag} ${OldLUTtag}
echo 'eos ls /eos/cms/store/group/dpg_hcal/comm_hcal/chin/'
echo 'eos ls $outdir'
make_line 
eos ls $outdir
echo conditions/${NewLUTtag}
eos mkdir $outdir/${NewLUTtag}
eos mkdir $outdir/${NewLUTtag}/L1Plots
xrdcp -rf conditions/${NewLUTtag} $outdir/${NewLUTtag}

echo
echo " "
make_line
echo " L1TriggerObjects Tag generation"
make_line

ls conditions/$NewLUTtag/Deploy/
cp conditions/$NewLUTtag/Deploy/Gen_L1TriggerObjects_${NewLUTtag}.txt ../../..
cd ../../..
cp ../../ConditionsValidation/Tools/writetoSQL9x.csh .
chmod +x writetoSQL9x.csh
./writetoSQL9x.csh $geometry L1TriggerObjects Gen_L1TriggerObjects_${NewLUTtag}.txt Tag 1 HcalL1TriggerObjects.db
xrdcp -f HcalL1TriggerObjects.db $outdir/${NewLUTtag}/HcalL1TriggerObjects.db
echo 'eos ls /eos/cms/store/group/dpg_hcal/comm_hcal/chin/'
eos ls $outdir/${NewLUTtag}/.

echo " "
make_line
echo " L1 rate validation"
make_line
cd ../..
scram -a $arch_L1 project $release_L1

cd ${release_L1}/src
eval `scram runtime -sh`
git cms-init
git remote add cms-l1t-offline git@github.com:cms-l1t-offline/cmssw.git
git fetch -u cms-l1t-offline l1t-integration-${release_L1}
git cms-merge-topic -u cms-l1t-offline:l1t-integration-v${version_L1}
git clone https://github.com/cms-l1t-offline/L1Trigger-L1TCalorimeter.git L1Trigger/L1TCalorimeter/data
git cms-checkdeps -A -a
scram b -j 8
#----------------------------------------------------------------------------------------------------
git clone git@github.com:cms-hcal-trigger/Validation.git HcalTrigger/Validation
scram b -j 8
cd HcalTrigger/Validation/scripts

mkdir hcal_${run}_def
mkdir hcal_${run}_new_cond

cp ../../../../../ConditionsValidation/Tools/ntuple_maker_template.sh ./
cp ../../../../../$release_LUT/src/HcalL1TriggerObjects.db .
cp ../../../../../$release_LUT/src/HcalL1TriggerObjects.db ./hcal_${run}_def
cp ../../../../../$release_LUT/src/HcalL1TriggerObjects.db ./hcal_${run}_new_cond
ls
if [[ ! $lumiblock == \#* ]]; then
  echo "{\"$run\": [[$lumi_start,$lumi_end]]}" > ./lumimask.txt
  lumimask="../../lumimask.txt"
fi

dasgoclient -query="file dataset=${dataset} run=${run}" > $listFiles
n=0
for file in `less ./${listFiles}`; do
  n=$[$n+1]
  echo "$n. $file"
  if (( "$n" <= "$max_file_num" )) || (( "$max_file_num" < 0 ))
  then
    numfolder=(`find ./hcal_${run}_def/  -maxdepth 1 -name "ntuple_maker_*" -type d | wc -l`)
    mkdir -p ./hcal_${run}_def/ntuple_maker_$numfolder && mkdir -p ./hcal_${run}_new_cond/ntuple_maker_$numfolder
    sh ./ntuple_maker_template.sh default $n $nEvts Run3 $OldGT root://cms-xrd-global.cern.ch//$file $lumimask && mv ntuple_maker_def_$n.py ./hcal_${run}_def/ntuple_maker_$numfolder
    sh ./ntuple_maker_template.sh new_con $n $nEvts Run3 $NewGT root://cms-xrd-global.cern.ch//$file $lumimask && mv ntuple_maker_new_$n.py ./hcal_${run}_new_cond/ntuple_maker_$numfolder
    ( cd ./hcal_${run}_def/ntuple_maker_$numfolder && cmsRun ntuple_maker_def_$n.py && mv L1Ntuple.root ../L1Ntuple_$n.root ) & ( cd ./hcal_${run}_new_cond/ntuple_maker_$numfolder && cmsRun ntuple_maker_new_$n.py && mv L1Ntuple.root ../L1Ntuple_$n.root ) &
#    wait
    if [ $(jobs | wc -l) -ge $jobs_in_parallel ]; then
      echo "Waiting for background processes to finish ..."
      wait
      rm -r ./hcal_${run}_def/ntuple_maker_*
      rm -r ./hcal_${run}_new_cond/ntuple_maker_*
    fi
  else
    break
  fi
done

echo "Waiting for background processes to finish ..."
wait

rates.exe def ./hcal_${run}_def/
rates.exe new ./hcal_${run}_new_cond/
mkdir plots
draw_rates.exe
ls plots
xrdcp -rf plots ${outdir}/${NewLUTtag}/L1Plots
