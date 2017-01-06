#!/bin/bash -ex
export LANG=en_US.UTF-8

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

java -Xms16G -Xmx16G -jar "$CWD/../../../maxmax/target/maxmax.jar" \
     -in "$CWD/../../data/edges.txt" -out "$CWD/../maxmax-clusters.txt"

$CWD/../delabel.awk "$CWD/../maxmax-clusters.txt" > "$CWD/../maxmax-synsets.tsv"
rm -fv "$CWD/../maxmax-clusters.txt"

# Apparently, MaxMax tends to emit very large synsets that
# have no sense (check it yourself). There is no reason to
# evaluate them due to the computational complexity.
$CWD/../../pairs.awk -v N=100 "$CWD/../maxmax-synsets.tsv" > "$CWD/../maxmax-pairs.txt"
