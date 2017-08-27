#!/bin/bash -ex
export LANG=en_US.UTF-8 LC_COLLATE=C

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

EDGES="${EDGES:-$CWD/../../data/edges.txt}"

DATA=$(mktemp -d)

trap 'rm -rf -- "$DATA"' INT TERM HUP EXIT

awk 'BEGIN { FS = OFS = "\t"; } $1 <= $2 { print $1, $2, $3; } $1 > $2 { print $2, $1, $3; }' "$CWD/../../data/edges.txt" |
sort --parallel=$(nproc) -S1G -t $'\t' -u -k1 -k2 -o "$EDGES"

rm -fv "$CWD/../eco-mcl.txt.xz"

for i in $(seq 30); do
  $CWD/noise.awk "$EDGES" > "$DATA/edges-$i.txt"

  $CWD/../../../mcl-14-137/bin/mcl "$DATA/edges-$i.txt" \
    -te $(nproc) -I 1.6 --abc -o "$DATA/clusters-$i.txt" 2>/dev/null

  xz -T $(nproc) "$DATA/clusters-$i.txt" -c >>"$CWD/../eco-mcl.txt.xz"

  rm -fv "$DATA/clusters-$i.txt"
done

xzcat "$CWD/../eco-mcl.txt.xz" | $CWD/discover.py | $CWD/../delabel.awk > "$CWD/../eco-synsets.tsv"

$CWD/../../pairs.awk "$CWD/../eco-synsets.tsv" > "$CWD/../eco-pairs.txt"
