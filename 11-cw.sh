#!/bin/bash -ex
# Possible cwOption values are TOP, DIST_LOG, and DIST_NOLOG
export LANG=en_US.UTF-8
cwOption=${1:-TOP}

LC_ALL=C sort --parallel=8 -s -o 11-senses.txt 10-senses.txt

java -Xms16G -Xmx16G -cp $PWD/../chinese-whispers/target/chinese-whispers.jar \
     de.tudarmstadt.lt.cw.global.CWGlobal -N 200 -cwOption $cwOption \
     -in '11-senses.txt' -out '11-synsets.txt'
