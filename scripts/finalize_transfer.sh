#!/bin/bash

make_line
echo "Transfering final output"
make_line

if [[ ! "$local_out" == "true" ]]; then
    echo "xrdcp -rf $OUTDIR $transferdir"
    xrdcp -rf $OUTDIR $transferdir
fi
