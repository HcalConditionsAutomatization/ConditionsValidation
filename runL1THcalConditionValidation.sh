#!/bin/bash

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

    # Generate the Lookup Tables based on the conditions, both new and old
    bash scripts/lutgen.sh

    # Generate trigger objects for the new LUT tag
    bash scripts/l1tag.sh

    # Compute the L1 rates
    bash scripts/l1rate.sh

    # Make Plots
    bash scripts/makeplots.sh
}

main


