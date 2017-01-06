#!/usr/bin/awk -f
BEGIN {
    FS = OFS = "\t";
}
{
    for (i = 1; i <= split($3, words, ", "); i++) {
        if (TOLOWER) words[i] = tolower(words[i]);
        print words[i] | "sort --parallel=$(nproc) -S1G -us";
    }
}
