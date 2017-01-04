#!/usr/bin/awk -f
BEGIN{
    FS = OFS = "\t";
}
{
    split($3, words, ", ");
    for (i = 1; i <= length(words) - 1; i++) {
        for (j = i + 1; j <= length(words); j++) {
            print words[i], words[j];
            print words[j], words[i];
        }
    }
}
