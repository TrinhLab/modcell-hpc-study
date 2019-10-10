# Description
Benchmarks of MOEA parameters for different cases.
Scripts are run in the following order:
1. `make_scripts`: This will generate `*.pbs` and `*_cons.sh` scripts. The `*.pbs` are run to obtain populations. The `*_cons.sh` obtain the combined populations. This directory must also contain `case_info.tsv` which contains `<case_path>\t<alpha>`
2. `consolidate_pops`: Consolidates .pops from different PEs into one .pop file.
3. `get_pops_csv`: Converts .pop files to csv format. Can be a bit slow for large populations due to non-domination calculation. Use a single core so could be edited to use gnu parallel for better performance. (or pop2csv.py could be further optimize) For the combined population, since this file can be quite large, but contains a lot of duplicates, a script to speed this up `combined_pop2csv.py` can be used.
4. `get_metrics`: Calculates MOEA metrics from the populations using `calc_metrics.m`
5. `get_results_table.py`: Formats the metrics into a nice table.

Use `./run_all <absolute_path>` to run all of them.

# Notes:
The cat(ed) populations all.pop are not kept track of in git due to their large size.

#  modcell-hpc version
 - The calculations were done on NICS-ACF machine
 - The binaries for each results come from the following commit hashes:
	- gem-model-1hr, f2a9b951ee403ac6757d538fe6e8ac2a16507eff
	- gem-model-nomr, f2a9b951ee403ac6757d538fe6e8ac2a16507eff
	- gem-model-2hr, 9958c43100015488ca7e032c15ba818a315bfb05
	- gem-native,20fb1064f5a920258f44bb0f4c3e9da7ddb287e6
