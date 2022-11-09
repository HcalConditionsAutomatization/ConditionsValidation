#!/bin/bash
make_line
echo "Constructing summary presentations"
make_line

cd $BASE_PATH/ConditionsValidation

python3 -m PostAnalysis.make_overview configuration/post_conf.py
