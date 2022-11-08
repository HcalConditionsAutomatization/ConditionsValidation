#!/bin/bash

make_line
echo "Transfering final output"
make_line

if [[ ! "$local_out" == "true" ]]; then
    xrdcp -rf $outdir $transferdir
fi
