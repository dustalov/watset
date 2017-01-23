#!/usr/bin/awk -f
BEGIN {
    print "<ruthes>";
}
{
    print $0;
}
END {
    print "</ruthes>";
}
