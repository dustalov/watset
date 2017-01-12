#!/usr/bin/awk -f
BEGIN {
    FS = OFS = "\t";
    if (length(T) == 0) T = 150;
}
{
    len = split($3, words, ", ");

    if (T != 0 && len >= T) next;

    for (i = 1; i <= len - 1; i++) {
        for (j = i + 1; j <= len; j++) {
            if (words[i] != words[j]) {
                print words[i], words[j] ORS words[j], words[i] | "sort --parallel=$(nproc) -t \"\t\" -S1G -k1 -k2 -s";
            }
        }
    }
}
