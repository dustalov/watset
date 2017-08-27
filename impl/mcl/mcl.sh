#!/bin/bash -ex
export LANG=en_US.UTF-8 LC_COLLATE=C

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

EDGES="${EDGES:-$CWD/../../data/edges.txt}"

$CWD/../../../mcl-14-137/bin/mcl "$EDGES" \
  -te $(nproc) --abc -o "$CWD/../mcl-clusters.txt" 2>/dev/null

$CWD/format.awk "$CWD/../mcl-clusters.txt" | $CWD/../delabel.awk > "$CWD/../mcl-synsets.tsv"
$CWD/../../pairs.awk "$CWD/../mcl-synsets.tsv" > "$CWD/../mcl-pairs.txt"
rm -fv "$CWD/../mcl-clusters.txt"
