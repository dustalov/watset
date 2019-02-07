#!/usr/bin/gawk -f
BEGIN {
    if (length(TAG) == 0) TAG = "ruthes";
    print "<" TAG ">";
}
{
    print $0;
}
END {
    print "</" TAG ">";
}
