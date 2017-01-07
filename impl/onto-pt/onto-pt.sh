#!/bin/bash -ex
export LANG=en_US.UTF-8

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DATA=$(mktemp -d)

trap 'rm -rf -- "$DATA"' INT TERM HUP EXIT

$CWD/components.py < "$CWD/../../data/edges.txt" |
sort --parallel=$(nproc) -t $'\t' -k1n -o "$CWD/../onto-pt-components.txt"

COMPONENTS=$(tail -1 "$CWD/../onto-pt-components.txt" | cut -f1)

RUNS=30

for i in $(seq $COMPONENTS); do
  # We do not want to reach the maximum files per directory limit.
  BLOCK="$DATA/$((i % 100))"
  mkdir -p "$BLOCK"

  # Seriously, there is no reason to expect anything useful
  # in the clusters with only a couple of elements.
  if [ "$i" -le "300" ]; then
    for j in $(seq $RUNS); do
      $CWD/component.awk -v C=$i "$CWD/../onto-pt-components.txt" > "$BLOCK/component-$i-$j.txt"
      $CWD/../../../mcl-14-137/bin/mcl "$BLOCK/component-$i-$j.txt" \
        -te $(nproc) -I 1.6 --abc -o "$BLOCK/cluster-$i-$j.txt" 2>/dev/null
    done
  else
    $CWD/component.awk -v C=$i "$CWD/../onto-pt-components.txt" > "$BLOCK/component-$i-1.txt"
    for j in $(seq $RUNS); do
      $CWD/replicate.awk "$BLOCK/component-$i-$j.txt" > "$BLOCK/cluster-$i-$j.txt"
    done
  fi
done

find "$DATA" -name 'cluster-*-*.txt' -exec cat {} \; > "$CWD/../onto-pt-mcl.txt"

$CWD/discover.py < "$CWD/../onto-pt-mcl.txt" > "$CWD/../onto-pt-clusters.txt"

$CWD/cleanup.py < "$CWD/../onto-pt-clusters.txt" | $CWD/../delabel.awk > "$CWD/../onto-pt-synsets.tsv"
$CWD/../../pairs.awk "$CWD/../onto-pt-synsets.tsv" > "$CWD/../onto-pt-pairs.txt"
