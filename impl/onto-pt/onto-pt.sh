#!/bin/bash -ex
export LANG=en_US.UTF-8 LC_COLLATE=C

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DATA=$(mktemp -d)

trap 'rm -rf -- "$DATA"' INT TERM HUP EXIT

awk 'BEGIN { FS = OFS = "\t"; } $1 <= $2 { print $1, $2, $3; } $1 > $2 { print $2, $1, $3; }' "$CWD/../../data/edges.txt" |
sort --parallel=$(nproc) -S1G -t $'\t' -su -k1 -k2 -o "$DATA/edges.txt"

for i in $(seq 30); do
  $CWD/noise.awk "$DATA/edges.txt" > "$DATA/edges-$i.txt"

  $CWD/../../../mcl-14-137/bin/mcl "$DATA/edges-$i.txt" \
    -te $(nproc) -I 1.6 --abc -o "$DATA/clusters-$i.txt" 2>/dev/null
done

find "$DATA" -name 'clusters-*.txt' -exec cat {} \; > "$CWD/../onto-pt-mcl.txt"

$CWD/discover.py < "$CWD/../onto-pt-mcl.txt" | $CWD/../delabel.awk > "$CWD/../onto-pt-synsets.tsv"

$CWD/../../pairs.awk "$CWD/../onto-pt-synsets.tsv" > "$CWD/../onto-pt-pairs.txt"
