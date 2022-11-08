#!/bin/bash
make_line
echo "Constructing summary presentations"
make_line

cd $BASE_PATH/ConditionsValidation

python3 -m Tools.PresentationTools.make_overview
