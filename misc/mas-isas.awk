#!/usr/bin/awk -f
BEGIN {
    FS  = 0;
    OFS = "\t";
}
/^\t/ {
    gsub(/(^\t| \{.*|')/, "");
    gsub(/ - /, OFS);
    print $0;
}
