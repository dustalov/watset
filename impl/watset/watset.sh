#!/bin/bash -ex
export LANG=en_US.UTF-8 LC_COLLATE=C

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

java -Xms16G -Xmx16G -cp "$CWD/../../../chinese-whispers/target/chinese-whispers.jar" \
     de.tudarmstadt.lt.wsi.WSI -clustering cw -cwOption TOP -N 200 -n 200 -e 0 \
     -in "$CWD/../../data/edges.txt" -out "$CWD/../watset-wsi-cw-top.txt" | grep -i process

java -Xms16G -Xmx16G -cp "$CWD/../../../chinese-whispers/target/chinese-whispers.jar" \
     de.tudarmstadt.lt.wsi.WSI -clustering cw -cwOption DIST_LOG -N 200 -n 200 -e 0 \
     -in "$CWD/../../data/edges.txt" -out "$CWD/../watset-wsi-cw-log.txt" | grep -i process

java -Xms16G -Xmx16G -cp "$CWD/../../../chinese-whispers/target/chinese-whispers.jar" \
     de.tudarmstadt.lt.wsi.WSI -clustering cw -cwOption DIST_NOLOG -N 200 -n 200 -e 0 \
     -in "$CWD/../../data/edges.txt" -out "$CWD/../watset-wsi-cw-nolog.txt" | grep -i process

java -Xms16G -Xmx16G -cp "$CWD/../../../chinese-whispers/target/chinese-whispers.jar" \
     de.tudarmstadt.lt.wsi.WSI -clustering mcl -N 200 -n 200 -e 0 \
     -in "$CWD/../../data/edges.txt" -out "$CWD/../watset-wsi-mcl.txt" | grep -i process

for setup in cw-top cw-log cw-nolog mcl; do
  $CWD/disambiguate.py "$CWD/../watset-wsi-$setup.txt" > "$CWD/../watset-$setup-senses.txt"

  sort --parallel=$(nproc) -so "$CWD/../watset-$setup-senses.txt" "$CWD/../watset-$setup-senses.txt"

  java -Xms16G -Xmx16G -cp "$CWD/../../../chinese-whispers/target/chinese-whispers.jar" \
       de.tudarmstadt.lt.cw.global.CWGlobal -N 200 -cwOption TOP \
       -in "$CWD/../watset-$setup-senses.txt" -out "$CWD/../watset-$setup-cw-top-clusters.txt" | grep -i process

  $CWD/../delabel.awk "$CWD/../watset-$setup-cw-top-clusters.txt" > "$CWD/../watset-$setup-cw-top-synsets.tsv"
  $CWD/../../pairs.awk "$CWD/../watset-$setup-cw-top-synsets.tsv" > "$CWD/../watset-$setup-cw-top-pairs.txt"

  java -Xms16G -Xmx16G -cp "$CWD/../../../chinese-whispers/target/chinese-whispers.jar" \
       de.tudarmstadt.lt.cw.global.CWGlobal -N 200 -cwOption DIST_LOG \
       -in "$CWD/../watset-$setup-senses.txt" -out "$CWD/../watset-$setup-cw-log-clusters.txt" | grep -i process

  $CWD/../delabel.awk "$CWD/../watset-$setup-cw-log-clusters.txt" > "$CWD/../watset-$setup-cw-log-synsets.tsv"
  $CWD/../../pairs.awk "$CWD/../watset-$setup-cw-log-synsets.tsv" > "$CWD/../watset-$setup-cw-log-pairs.txt"

  java -Xms16G -Xmx16G -cp "$CWD/../../../chinese-whispers/target/chinese-whispers.jar" \
       de.tudarmstadt.lt.cw.global.CWGlobal -N 200 -cwOption DIST_NOLOG \
       -in "$CWD/../watset-$setup-senses.txt" -out "$CWD/../watset-$setup-cw-nolog-clusters.txt" | grep -i process

  $CWD/../delabel.awk "$CWD/../watset-$setup-cw-nolog-clusters.txt" > "$CWD/../watset-$setup-cw-nolog-synsets.tsv"
  $CWD/../../pairs.awk "$CWD/../watset-$setup-cw-nolog-synsets.tsv" > "$CWD/../watset-$setup-cw-nolog-pairs.txt"

  $CWD/../../../mcl-14-137/bin/mcl "$CWD/../watset-$setup-senses.txt" \
    -te $(nproc) --abc -o "$CWD/../watset-$setup-mcl-clusters.txt" 2>/dev/null

  $CWD/../mcl/format.awk "$CWD/../watset-$setup-mcl-clusters.txt" | $CWD/../delabel.awk > "$CWD/../watset-$setup-mcl-synsets.tsv"
  $CWD/../../pairs.awk "$CWD/../watset-$setup-mcl-synsets.tsv" > "$CWD/../watset-$setup-mcl-pairs.txt"
done
