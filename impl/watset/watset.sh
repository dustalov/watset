#!/bin/bash -ex
export LANG=en_US.UTF-8

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

java -Xms16G -Xmx16G -cp "$CWD/../../../chinese-whispers/target/chinese-whispers.jar" \
     de.tudarmstadt.lt.wsi.WSI -clustering cw -cwOption TOP -N 200 -n 200 -e 0 \
     -in "$CWD/../../data/edges.txt" -out "$CWD/../watset-wsi-cw-top.txt"

java -Xms16G -Xmx16G -cp "$CWD/../../../chinese-whispers/target/chinese-whispers.jar" \
     de.tudarmstadt.lt.wsi.WSI -clustering cw -cwOption DIST_LOG -N 200 -n 200 -e 0 \
     -in "$CWD/../../data/edges.txt" -out "$CWD/../watset-wsi-cw-log.txt"

java -Xms16G -Xmx16G -cp "$CWD/../../../chinese-whispers/target/chinese-whispers.jar" \
     de.tudarmstadt.lt.wsi.WSI -clustering cw -cwOption DIST_NOLOG -N 200 -n 200 -e 0 \
     -in "$CWD/../../data/edges.txt" -out "$CWD/../watset-wsi-cw-nolog.txt"

# This one is really annoying.
java -Xms16G -Xmx16G -cp "$CWD/../../../chinese-whispers/target/chinese-whispers.jar" \
     de.tudarmstadt.lt.wsi.WSI -clustering mcl -N 200 -n 200 -e 0 \
     -in "$CWD/../../data/edges.txt" -out "$CWD/../watset-wsi-mcl.txt" >/dev/null

for setup in cw-top cw-log cw-nolog mcl; do
  sort --parallel=$(nproc) -s -o "$CWD/../watset-wsi-$setup.txt" "$CWD/../watset-wsi-$setup.txt"

  $CWD/disambiguate.py "$CWD/../watset-wsi-$setup.txt" >"$CWD/../watset-$setup-senses.txt"

  java -Xms16G -Xmx16G -cp "$CWD/../../../chinese-whispers/target/chinese-whispers.jar" \
       de.tudarmstadt.lt.cw.global.CWGlobal -N 200 -cwOption TOP \
       -in "$CWD/../watset-$setup-senses.txt" -out "$CWD/../watset-$setup-cw-top-clusters.txt"

  $CWD/../delabel.awk "$CWD/../watset-$setup-cw-top-clusters.txt" > "$CWD/../watset-$setup-cw-top-synsets.tsv"
  $CWD/../../pairs.awk "$CWD/../watset-$setup-cw-top-synsets.tsv" > "$CWD/../watset-$setup-cw-top-pairs.txt"
  sort --parallel=$(nproc) -uso "$CWD/../watset-$setup-cw-top-pairs.txt" "$CWD/../watset-$setup-cw-top-pairs.txt"

  java -Xms16G -Xmx16G -cp "$CWD/../../../chinese-whispers/target/chinese-whispers.jar" \
       de.tudarmstadt.lt.cw.global.CWGlobal -N 200 -cwOption DIST_LOG \
       -in "$CWD/../watset-$setup-senses.txt" -out "$CWD/../watset-$setup-cw-log-clusters.txt"

  $CWD/../delabel.awk "$CWD/../watset-$setup-cw-log-clusters.txt" > "$CWD/../watset-$setup-cw-log-synsets.tsv"
  $CWD/../../pairs.awk "$CWD/../watset-$setup-cw-log-synsets.tsv" > "$CWD/../watset-$setup-cw-log-pairs.txt"
  sort --parallel=$(nproc) -uso "$CWD/../watset-$setup-cw-log-pairs.txt" "$CWD/../watset-$setup-cw-log-pairs.txt"

  java -Xms16G -Xmx16G -cp "$CWD/../../../chinese-whispers/target/chinese-whispers.jar" \
       de.tudarmstadt.lt.cw.global.CWGlobal -N 200 -cwOption DIST_NOLOG \
       -in "$CWD/../watset-$setup-senses.txt" -out "$CWD/../watset-$setup-cw-nolog-clusters.txt"

  $CWD/../delabel.awk "$CWD/../watset-$setup-cw-nolog-clusters.txt" > "$CWD/../watset-$setup-cw-nolog-synsets.tsv"
  $CWD/../../pairs.awk "$CWD/../watset-$setup-cw-nolog-synsets.tsv" > "$CWD/../watset-$setup-cw-nolog-pairs.txt"
  sort --parallel=$(nproc) -uso "$CWD/../watset-$setup-cw-nolog-synsets.tsv" "$CWD/../watset-$setup-cw-nolog-synsets.tsv"
done
