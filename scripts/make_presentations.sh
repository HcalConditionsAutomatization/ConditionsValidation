#!/bin/bash
make_line
echo "Constructing summary presentations"
make_line

cd $BASE_PATH/ConditionsValidation

python3 -m venv env
source env/bin/activate
cd $BASE_PATH/${release_L1}/src
cmsenv
cd $BASE_PATH/ConditionsValidation

python3 -m PostAnalysis configuration/post_conf.py
