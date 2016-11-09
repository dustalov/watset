#!/usr/bin/awk -f
# echo -e 'words\ncar;auto;ride' | ./00-extract.awk
BEGIN {
    FS  = "\t";
    OFS = "\t";
}
$4 == "synonyms" {
    print $2, $3;
    print $3, $2;
}
