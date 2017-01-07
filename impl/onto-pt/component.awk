#!/usr/bin/awk -f
BEGIN {
    FS = OFS = "\t";
    srand();
}
C == $1 {
    $4 *= 1 + (rand() - 0.5);
    print $2, $3, $4 ORS $3, $2, $4 | "sort --parallel=$(nproc) -su";
}
