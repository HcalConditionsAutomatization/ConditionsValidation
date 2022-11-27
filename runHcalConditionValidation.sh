#!/bin/bash


export DEFAULT_LINE_LENGTH=35
export jobs_in_parallel=10
export MAX_LEN=0
export listFiles="listOfFiles.txt"
export BASE_PATH="$(dirname $(pwd))"
export OUTDIR="$BASE_PATH/$outdir/$NewLUTtag"
export GIT_COMMIT=$(git rev-parse HEAD)
export SCRATCH_DIR="$BASE_PATH/scratch"
if [[ $local_out == "true" ]]; then
   export LOG_DIR=$BASE_PATH/logs
else
   export LOG_DIR=$CI_UPLOAD_DIR
fi


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
           "jobs_in_parallel" "calo_params" "zdc_lut_topic" "transferdir"
           "release_HLT" "arch_HLT" "hlt_max_events" "hlt_dataset" "hlt_paths"
           )

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

    mkdir -p $SCRATCH_DIR
    mkdir -p $LOG_DIR

    make_line
    echo "Running from BASE_PATH ${BASE_PATH}"
    echo "Scratch directory is ${SCRATCH_DIR}"
    echo "Git status is"
    git status
    make_line

    print_vars


    bash scripts/setup_python.sh

    # Generate the Lookup Tables based on the conditions, both new and old
    bash scripts/lutgen.sh

    # Generate trigger objects for the new LUT tag
    bash scripts/l1tag.sh

    # Compute the L1 rates
    bash scripts/l1rate.sh

    # Make Plots
    bash scripts/makeplots.sh

    # Start HLT Validation
    #bash scripts/hlt.sh

    # Make Prsentations
    bash scripts/make_presentations.sh

    # Transfer output to eos
    bash scripts/finalize_transfer.sh

    make_line
    echo "Validation completed"
    make_line
}

main


