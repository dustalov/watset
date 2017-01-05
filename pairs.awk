#!/usr/bin/awk -f
BEGIN {
    FS  = "\t";
    OFS = "";
}
{
    len = split($3, words, ", ");

    if (length(N) > 0 && len >= N) next;

    for (i = 1; i <= len - 1; i++) {
        for (j = i + 1; j <= len; j++) {
            print words[i], FS, words[j], ORS, words[j], FS, words[i] | "sort --parallel=$(nproc) -S1G -us";
        }
    }
}
