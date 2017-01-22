#!/bin/bash -ex
export LANG=en_US.UTF-8 LC_COLLATE=C

./link.py --synsets synsets.tsv --isas=pairs.txt >links.tsv
./join.py --synsets synsets.tsv --links=links.tsv | sort -t $'\t' -k2nr -k1n -o joint.tsv

sort --parallel=$(nproc) -S1G -t $'\t' -k1,1 -k2,2 -uo pairs-expanded.txt \
  <pairs.txt <(./expanded.awk pairs-expansion.txt)

./link.py --synsets synsets.tsv --isas=pairs-expanded.txt >links-expanded.tsv
./join.py --synsets synsets.tsv --links=links-expanded.tsv | sort -t $'\t' -k2nr -k1n -o joint-expanded.tsv
