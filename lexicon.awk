#!/usr/bin/awk -f
BEGIN {
    FS = OFS = "\t";
}
{
    for (i = 1; i <= split($3, words, ", "); i++) {
        gsub("_", " ", words[i]);
        print words[i] | "sort -us";
    }
}
