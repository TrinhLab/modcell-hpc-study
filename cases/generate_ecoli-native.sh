#!/bin/sh

set -e
prodnet_path="${MODCELLHPC_S_PATH}/cases/ecoli-native-matlab/prodnet.mat"
case_path="${MODCELLHPC_S_PATH}/cases/ecoli-native"

temp_script=$(mktemp)
echo "cd  $case_path" >> $temp_script
echo "prodnet2txt(\"${prodnet_path}\")" >> $temp_script
eval "$MATLAB_BIN -nodesktop -nodisplay -sd ~/wrk/s/matlab < $temp_script"

