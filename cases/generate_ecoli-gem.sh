#!/bin/sh

rm ecoli-gem/*
cd ecoli-gem

prodnet_path="${MODCELL2_PATH}/problems/ecoli-gem/prodnet-known-l.mat"
temp_script=$(mktemp)

echo "cd  ${MODCELLHPC_PATH}/cases/ecoli-gem" >> $temp_script
echo "prodnet2txt(\"${prodnet_path}\")" >> $temp_script

~/progs/matlab/bin/matlab -nodesktop -nodisplay -sd ~/wrk/s/matlab < $temp_script

