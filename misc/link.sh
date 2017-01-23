#!/bin/bash -ex
export LANG=en_US.UTF-8 LC_COLLATE=C

./link.py --synsets=synsets.tsv --isas=pairs.txt | sort -t $'\t' -k2nr -k4nr -k1n -o joint.new.tsv

sort --parallel=$(nproc) -S1G -t $'\t' -k1,1 -k2,2 -uo pairs-expanded.txt <pairs.txt <(./expanded.awk pairs-expansion.txt)
./link.py --synsets=synsets.tsv --isas=pairs-expanded.txt | sort -t $'\t' -k2nr -k4nr -k1n -o joint-expanded.new.tsv
