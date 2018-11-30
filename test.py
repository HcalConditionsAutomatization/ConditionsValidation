#!/usr/bin/env python
'''Example of generating two sets of LUTs and comparisons
for validation.'''
import os
import sys

RUNS = [sys.argv[4], sys.argv[1]]
CONDITIONS = ["ChannelQuality", "Pedestals", "Gains", "RespCorrs", 
              "ElectronicsMap", "TPParameters", "TPChannelParameters", 
              "LUTCorrs", "QIEData", "QIETypes", "LutMetadata"]
TAGS = {sys.argv[4] : [sys.argv[5], sys.argv[6]], sys.argv[1] : [sys.argv[2], sys.argv[3]]}
COMMENT = "validation"

# dump conditions; used for inputs to LUT generation
# and for comparisons of gain*resp_corr versus LUT slope
for run in RUNS:
    for condition in CONDITIONS:
        dump_cmd = "./genLUT.sh dump "
        dump_cmd += "record=" + condition + " run=" + run + " GT=" + TAGS[run][1]
        #os.system(dump_cmd)
        print(dump_cmd)

# generate LUTs. Two sets of LUTs are generated here so that the comparison 
# tests can be run. This will create two new sets of files 
# in the "conditions" directory.
for run in RUNS:
    gen_cmd = "./genLUT.sh generate"
    gen_cmd += " GT=" + TAGS[run][1]
    gen_cmd += " run=" + run 
    gen_cmd += " tag=" + TAGS[run][0] 
    gen_cmd += " comment=" + COMMENT
    gen_cmd += " HO_master_file=HO_ped9_inputLUTcoderDec.txt"
    for condition in CONDITIONS:
        gen_cmd += " " + condition + "=" + run
    #os.system(gen_cmd)
    print(gen_cmd)

# run validation
validate_cmd = "./genLUT.sh validate GT=" + TAGS[RUNS[0]][1] 
validate_cmd += " run=" + str(RUNS[0]) 
validate_cmd += " tags=" + TAGS[RUNS[0]][0] + "," + TAGS[RUNS[1]][0]
validate_cmd += " quality=" + RUNS[0] + "," + RUNS[1]
validate_cmd += " pedestals=" + RUNS[0] + "," + RUNS[1]
validate_cmd += " respcorrs=" + RUNS[0] + "," + RUNS[1]
validate_cmd += " gains=" + RUNS[0] + "," + RUNS[1]
#os.system(validate_cmd)
print(validate_cmd)
