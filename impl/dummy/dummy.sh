#!/bin/bash -ex
export LANG=en_US.UTF-8 LC_COLLATE=C

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

EDGES="${EDGES:-$CWD/../../data/edges.txt}"

cut -f1 "$EDGES" |
sort --parallel=$(nproc) -u |
awk 'BEGIN { FS = OFS = "\t"; } { print NR, 1, $1; }' > $CWD/../dummy-synsets.tsv
cut -f1,2 "$EDGES" > $CWD/../dummy-pairs.txt
