#!/usr/bin/awk -f
BEGIN {
    FS = OFS = "\t";
}
{
    len = split($3, words, ", ");

    if (length(N) > 0 && len >= N) next;

    for (i = 1; i <= len - 1; i++) {
        for (j = i + 1; j <= len; j++) {
            print words[i], words[j];
            print words[j], words[i];
        }
    }
}