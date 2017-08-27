#!/bin/bash -ex
export LANG=en_US.UTF-8 LC_COLLATE=C

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

EDGES="${EDGES:-$CWD/../../data/edges.txt}"

for k in $(seq 2 4); do
  $CWD/cpm.py -k$k < "$EDGES" |
  $CWD/../delabel.awk > "$CWD/../cpm-k$k-synsets.tsv"
  $CWD/../../pairs.awk "$CWD/../cpm-k$k-synsets.tsv" > "$CWD/../cpm-k$k-pairs.txt"
done
