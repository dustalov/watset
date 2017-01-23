#!/usr/bin/awk -f
BEGIN {
    FS  = ", ";
    OFS = "\t";
    ORS = "";
}
{
    print NR, NF OFS;
    for (i = 1; i <= NF - 1; i++) print $i FS;
    print $NF, RS;
}
