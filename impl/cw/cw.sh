#!/bin/bash -ex
export LANG=en_US.UTF-8

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

java -Xms16G -Xmx16G -cp "$CWD/../../../chinese-whispers/target/chinese-whispers.jar" \
     de.tudarmstadt.lt.cw.global.CWGlobal -N 200 -cwOption TOP \
     -in "$CWD/../../data/edges.txt" -out "$CWD/../cw-top-clusters.txt"

$CWD/../delabel.awk "$CWD/../cw-top-clusters.txt" > "$CWD/../cw-top-synsets.tsv"
rm -fv "$CWD/../cw-top-clusters.txt"

java -Xms16G -Xmx16G -cp "$CWD/../../../chinese-whispers/target/chinese-whispers.jar" \
     de.tudarmstadt.lt.cw.global.CWGlobal -N 200 -cwOption DIST_LOG \
     -in "$CWD/../../data/edges.txt" -out "$CWD/../cw-log-clusters.txt"

$CWD/../delabel.awk "$CWD/../cw-log-clusters.txt" > "$CWD/../cw-log-synsets.tsv"
rm -fv "$CWD/../cw-log-clusters.txt"

java -Xms16G -Xmx16G -cp "$CWD/../../../chinese-whispers/target/chinese-whispers.jar" \
     de.tudarmstadt.lt.cw.global.CWGlobal -N 200 -cwOption DIST_NOLOG \
     -in "$CWD/../../data/edges.txt" -out "$CWD/../cw-nolog-clusters.txt"

$CWD/../delabel.awk "$CWD/../cw-nolog-clusters.txt" > "$CWD/../cw-nolog-synsets.tsv"
rm -fv "$CWD/../cw-nolog-clusters.txt"
