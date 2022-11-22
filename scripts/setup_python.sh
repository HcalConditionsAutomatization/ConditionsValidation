#!/bin/bash

make_line
echo "Setting Up Python"
make_line

python3 -m venv env
source env/bin/activate
pip install -r requirements.txt

