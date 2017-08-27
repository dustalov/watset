#!/bin/bash -ex
export LANG=en_US.UTF-8 LC_COLLATE=C

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

EDGES="${EDGES:-$CWD/../../data/edges.txt}"

java -Xms16G -Xmx16G -jar "$CWD/../../deps/maxmax.jar" \
     -in "$EDGES" -out "$CWD/../maxmax-clusters.txt"

$CWD/../delabel.awk "$CWD/../maxmax-clusters.txt" > "$CWD/../maxmax-synsets.tsv"
rm -fv "$CWD/../maxmax-clusters.txt"

# Apparently, MaxMax tends to emit very large synsets that
# have no sense (check it yourself). There is no reason to
# evaluate them due to the computational complexity.
$CWD/../../pairs.awk "$CWD/../maxmax-synsets.tsv" > "$CWD/../maxmax-pairs.txt"
