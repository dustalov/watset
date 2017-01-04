#!/usr/bin/awk -f
# echo -e 'words\ncar;auto;ride' | ./00-extract.awk
BEGIN {
    FS = OFS = "\t";
}
NF && $0!~/^#/ && $1~/.+/ {
    split($1, words, ",");
    for (i = 1; i <= length(words) - 1; i++) {
        for (j = i + 1; j <= length(words); j++) {
            gsub(/(^ +| +$)/, "", words[i]);
            gsub(/(^ +| +$)/, "", words[j]);
            gsub(/ /, "_", words[i]);
            gsub(/ /, "_", words[j]);
            print words[i], words[j];
            print words[j], words[i];
        }
    }
}
