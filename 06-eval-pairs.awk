#!/usr/bin/awk -f
BEGIN {
    FS = OFS = "\t";
}
{
    sub(", $", "");
    len = split($3, words, ", ");
    if (len >= 300) next;
    for (i = 1; i <= len; i++) {
        for (j = 1; j < i; j++) {
                                     word1 = words[i]; word2 = words[j];
            if (words[j] < words[i]) word1 = words[j]; word2 = words[i];
            gsub("_", " ", word1);
            gsub("_", " ", word2);
            if (word1 != word2) print word1, word2 | "sort -u -s";
        }
    }
}
