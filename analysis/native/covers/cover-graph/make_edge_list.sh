#!/bin/sh

input="a5_b1.covers"
output="edgelist.tsv"
outputattr="nodes.tsv"

printf "design\tcover\n" > $output
printf "node\ttype\n" > $outputattr

labels="abcdefghijklmnoprstxyz"
idx=1
grep "^\[" "$input" | sed -nE 's:\[(.*)\].*:\1:p' |\
while read -r x; do
	lab=$(echo $labels | cut -c$idx)
	echo "$x" | sed -En "s/([0-9]+), ([0-9]+), ([0-9]+).*/\1\t$lab\n\2\t$lab\n\3\t$lab/p" >> $output
	idx=$((idx+1))
	printf "${lab}\tcover\n" >> $outputattr
done

