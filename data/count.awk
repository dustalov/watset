#!/usr/bin/awk -f
# echo -e 'a\tb\na\tb\na\tc' | ./count.awk
BEGIN {
    FS = OFS = "\t";
}
NR == 1 {
    word1 = $1;
    word2 = $2;
}
("" word1 != $1) || ("" word2 != $2) {
    print word1, word2, count;
    word1 = $1;
    word2 = $2;
    count = 0;
}
{
    count++;
}
END {
    print word1, word2, count;
}
