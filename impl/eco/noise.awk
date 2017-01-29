#!/usr/bin/awk -f
BEGIN {
    FS = OFS = "\t";
    srand();
}
{
    $3 *= 1 + (rand() - 0.5);
    print $1, $2, $3 ORS $2, $1, $3 | "sort --parallel=$(nproc) -u";
}
