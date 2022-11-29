#!/bin/bash

make_line
echo "Setting Up Python"
make_line

python3 -m venv env
source env/bin/activate

echo "Now running in environment"
python3 -m pip -V

python3 -m pip install -r requirements.txt

