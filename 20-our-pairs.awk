#!/usr/bin/awk -f
BEGIN {
    FS = OFS = "\t";
}
{
    for (i = 1; i <= split($3, words, ", "); i++) {
        for (j = 1; j < i; j++) {
                                     word1 = words[i]; word2 = words[j];
            if (words[j] < words[i]) word1 = words[j]; word2 = words[i];
            if (word1 != word2) print word1, word2 | "sort -u -s";
        }
    }
}
