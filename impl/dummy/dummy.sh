#!/bin/bash -ex
export LANG=en_US.UTF-8 LC_ALL=C

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cut -f1 "$CWD/../../data/edges.txt" |
sort --parallel=$(nproc) -su |
awk 'BEGIN { FS = OFS = "\t"; } { print NR, 1, $1; }' > $CWD/../dummy-synsets.tsv
cut -f1,2 "$CWD/../../data/edges.txt" > $CWD/../dummy-pairs.txt
