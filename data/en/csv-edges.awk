#!/usr/bin/awk -f
BEGIN {
    FS = ", ";
    OFS = "\t";
}
{
    for (i = 1; i <= NF - 1; i++) {
        for (j = i + 1; j <= NF; j++) {
            if ($i != $j) print $i, $j ORS $j, $i
        }
    }
}
