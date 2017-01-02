#!/bin/bash -ex
# Possible cwOption values are TOP, DIST_LOG, and DIST_NOLOG
export LANG=en_US.UTF-8
cwOption=${1:-TOP}

java -Xms16G -Xmx16G -cp $PWD/../chinese-whispers/target/chinese-whispers.jar \
     de.tudarmstadt.lt.cw.global.CWGlobal -N 200 -cwOption $cwOption \
     -in '02-edges.txt' -out '03-cw.txt'

java -Xms16G -Xmx16G -cp $PWD/../chinese-whispers/target/chinese-whispers.jar \
     de.tudarmstadt.lt.wsi.WSI -clustering cw \
     -N 200 -n 200 -e 0 \
     -in '02-edges.txt' -out '03-cw-wsi.txt'

java -Xms16G -Xmx16G -jar $PWD/../maxmax/target/maxmax.jar \
     -in '02-edges.txt' -out '03-maxmax.txt'
