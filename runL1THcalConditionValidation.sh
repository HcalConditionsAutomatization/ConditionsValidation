#!/bin/bash

export DEFAULT_LINE_LENGTH=35
export jobs_in_parallel=10
export MAX_LEN=0
export listFiles="listOfFiles.txt"
export BASE_PATH="$(dirname $(pwd))"

echo "Running from BASE_PATH ${BASE_PATH}"

function make_line(){
    local length=${1:-$DEFAULT_LINE_LENGTH}
    head -c $length < /dev/zero | tr '\0' '='
    echo ""
}
export -f make_line

export variables=("HOAsciiInput" "release_L1" "NewLUTtag" "NewGT" 
           "dataset" "year" "nEvts" "lumi_start" "tier2" "OldRun" 
           "lumi_end" "version_L1" "OldLUTtag" "week" "run" "max_file_num" 
           "OldGT" "NewRun" "release_LUT" "outdir" "geometry" "arch_L1" "arch_LUT" 
           "jobs_in_parallel" "calo_params" "zdc_lut_topic")

function print_vars() {
    for var in ${variables[@]}; do
        : $(( MAX_LEN = (MAX_LEN > ${#var})? MAX_LEN : ${#var}  ))
    done
    make_line 
    for variable in ${variables[@]}; do
        printf "%-${MAX_LEN}s = %s\n" "$variable" "${!variable}"
    done
    make_line
}

function main(){
    print_vars

#    bash scripts/lutgen.sh
    bash scripts/l1tag.sh
    bash scripts/l1rate.sh
    bash scripts/makeplots.sh
}

main


