#!/usr/bin/awk -f
BEGIN {
    FS = OFS = "\t";
    if (length(N) == 0) N = 1;
}
NR == 1 {
    cluster = $1 OFS $2;
}
NR > 1 {
    cluster = cluster OFS $1 OFS $2;
}
END {
    for (i = 1; i <= N; i++) print cluster;
}
