#!/bin/bash -ex
export LANG=en_US.UTF-8

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

java -Xms16G -Xmx16G -jar "$CWD/../../../maxmax/target/maxmax.jar" \
     -in "$CWD/../../data/edges.txt" -out "$CWD/../maxmax-clusters.txt"

$CWD/../delabel.awk "$CWD/../maxmax-clusters.txt" > "$CWD/../maxmax-synsets.tsv"
rm -fv "$CWD/../maxmax-clusters.txt"
