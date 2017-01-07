#!/usr/bin/awk -f
BEGIN {
    FS = OFS = "\t";
    ORS = "";
}
NR == 1 {
    print $1, $2;
}
NR > 1 {
    print OFS $1, $2;
}
END {
    print RS;
}
