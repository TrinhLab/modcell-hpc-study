#!/bin/bash
# This script is borked, both cand and rxnidmap have 276 and 2764 unique elements respectively. So the join should yield 276
printf "Common cases %i\n" "$(join -t "," -2 2 <(sort cand) <(sort rxnidmap.csv) | wc -l)"
printf "Size of cand %i\n" "$(wc -l < cand)"
