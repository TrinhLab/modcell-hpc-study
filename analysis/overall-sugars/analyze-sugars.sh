#!/bin/sh

set -e

analysisdir="${MODCELLHPC_S_PATH}/analysis"

# Methods
create_plt() {
	cd "${analysisdir}/${1}/results"
	#mc_dir_pltcomp ./ -a [3,0,1,2] --output ../comp_0p5.svg
	mc_dir_pltcomp ./ -a [3,0,1,2] --output ../comp_0p5_n.svg --normalize -f2n "${analysisdir}/overall-sugars/labels.tsv" --y_ticks '[0,10,20,30,40,50,60]'
	cd "$analysisdir"
}

create_all_plt() {
	create_plt native-arabinose
	create_plt native-galactose
	create_plt native-mannose
	create_plt native-xylose
}

get_covers() {
	# REQUIRES to activate proper python environment!
	if [ "$#" != "2" ]; then
		echo "error. usage: $0 pf_path" && exit
	else
		pf_path=$1
		cover_path=$2
	fi

# Only enumerate top 100
mc_setcover "$pf_path"  --max 100 | tee "$cover_path"
}

get_all_covers(){
	params="a10_b2.csv"
	for sugar in arabinose galactose mannose xylose
	do
		pf_path="${analysisdir}/native-${sugar}/results/${params}"
		fbname=$(basename "$pf_path" .csv)
		cover_path="${analysisdir}/native-${sugar}/results/${fbname}.covers"
		get_covers $pf_path $cover_path
	done
}

generate_table() {
#This table is meant to be used as input to generate final table in python, also include glucose.
	parameters="a10_b2"
	printf "Parameters\tCarbon source\tCompatible products\tMinimal cover size\n" > properties.tsv
	for sugar in arabinose galactose mannose xylose
	do
		total_compatible=-1 # Do separetly
		covers_path="${analysisdir}/native-${sugar}/results/${parameters}.covers"
		minimal_cover_s=$(sed -n 's/Minimal cover size: \(.*\)/\1/p' $covers_path)

		printf "%s\t%s\t%d\t%d\n" $parameters $sugar $total_compatible $minimal_cover_s >> properties.tsv
	done
	# Add glucose
	covers_path="${analysisdir}/native/covers/${parameters}.covers"
	minimal_cover_s=$(sed -n 's/Minimal cover size: \(.*\)/\1/p' $covers_path)
	printf "%s\t%s\t%d\t%d\n" $parameters "glucose" $total_compatible $minimal_cover_s >> properties.tsv
}

generate_compatibility() {
	for sugar in arabinose galactose mannose xylose
	do
		res_path="${analysisdir}/native-${sugar}/results/"
		mc_dir_belowcomp $res_path > belowcomp_${sugar}.csv
	done
}

get_topdel() {

	params="a10_b2.csv"

	rxn_path="${analysisdir}/native/rxns.tsv"
	for sugar in arabinose galactose mannose xylose
	do
		pf_path="${analysisdir}/native-${sugar}/results/${params}"
		mc_gettopdeletions "$pf_path" "$rxn_path"
	done
}

# Run

#create_all_plt
#get_all_covers
#generate_table
#generate_compatibility
get_topdel


