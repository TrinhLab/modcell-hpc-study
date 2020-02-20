#!/bin/sh


curdir="${MODCELLHPC_S_PATH}/analysis/ctherm-ae-run"

# Methods
create_plt() {
	cd "./results"

	mc_dir_pltcomp ./ -t 0.5 --normalize --output ../comp_0p5.svgz --width 4 --height 3 -f2n ../labels.tsv --colors 3
	mc_dir_pltcomp ./ -t 0.6 --normalize --output ../comp_0p6.svgz --width 4 --height 3 -f2n ../labels.tsv --colors 3
	mc_dir_pltcomp ./ -t 0.8 --normalize --output ../comp_0p8.svgz --width 4 --height 3 -f2n ../labels.tsv --colors 3
	cd $curdir
}

#create_plt

create_pf() {
mc_pltpf results/a5_b0.csv -i2n  ../../cases/ctherm-ae-matlab/input/pathway_table.csv
mc_pltpf results/a6_b0.csv -i2n  ../../cases/ctherm-ae-matlab/input/pathway_table.csv --width 4 --height 4.5
}

create_pf

