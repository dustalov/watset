#!/usr/bin/awk -f
BEGIN {
    FS = "\t";

    URN           = "urn:swn:";

    LABEL         = "<http://www.w3.org/2000/01/rdf-schema#label>";
    TYPE          = "<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>";

    CONCEPT       = "<http://www.w3.org/2004/02/skos/core#Concept>";
    LEXICALSENSE  = "<http://lemon-model.net/lemon#LexicalSense>";
    WORD          = "<http://lemon-model.net/lemon#Word>";
    FORM          = "<http://lemon-model.net/lemon#Form>";

    WRITTENREP    = "<http://lemon-model.net/lemon#writtenRep>";
    CANONICALFORM = "<http://lemon-model.net/lemon#canonicalForm>";
    BROADER       = "<http://lemon-model.net/lemon#broader>";
    NARROWER      = "<http://lemon-model.net/lemon#narrower>";
    SENSE         = "<http://lemon-model.net/lemon#sense>";
    ISSENSEOF     = "<http://lemon-model.net/lemon#isSenseOf>";
    REFERENCE     = "<http://lemon-model.net/lemon#reference>";
    ISREFERENCEOF = "<http://lemon-model.net/lemon#isReferenceOf>";
}
{
    nsenses = split($3, senses, ", ");
    nisas   = split($5, isas,   ", ");

    if (nsenses == 0) next;

    print "<" URN "c" $1 ">", TYPE,  CONCEPT,            ".";
    print "<" URN "c" $1 ">", LABEL, "\"synset" $1 "\"", ".";

    for (sense_id in senses) {
        sense = senses[sense_id];

        sub(":.*$", "", sense);

        if (!(sense in sindex)) {
            sindex[sense] = scount++;

            word = sense;
            gsub("_", " ",  word);
            sub("#.*$", "", word);

            if (!(word in windex)) {
                windex[word] = wcount++;

                print "<" URN "w" windex[word] ">", TYPE,          WORD,                         ".";
                print "<" URN "w" windex[word] ">", LABEL,         "\"" word "\"",               ".";
                print "<" URN "f" windex[word] ">", TYPE,          FORM,                         ".";
                print "<" URN "f" windex[word] ">", LABEL,         "\"" word "\"",               ".";
                print "<" URN "f" windex[word] ">", WRITTENREP,    "\"" word "\"",               ".";
                print "<" URN "w" windex[word] ">", CANONICALFORM, "<" URN "f" windex[word] ">", ".";
            }

            print "<" URN "s" sindex[sense] ">", TYPE,          LEXICALSENSE,                  ".";
            print "<" URN "s" sindex[sense] ">", LABEL,         "\"" sense "\"",               ".";
            print "<" URN "s" sindex[sense] ">", ISSENSEOF,     "<" URN "w" windex[word] ">",  ".";
            print "<" URN "w" windex[word]  ">", SENSE,         "<" URN "s" sindex[sense] ">", ".";
            print "<" URN "s" sindex[sense] ">", REFERENCE,     "<" URN "c" $1 ">",            ".";
            print "<" URN "c" $1 ">",            ISREFERENCEOF, "<" URN "s" sindex[sense] ">", ".";
        }

        for (isa_id in isas) {
            isa = isas[isa_id];

            sub(":.*$", "", isa);

            if (!(isa in sindex)) {
                sindex[isa] = scount++;

                word = isa;
                gsub("_", " ",  word);
                sub("#.*$", "", word);

                if (!(word in windex)) {
                    windex[word] = wcount++;

                    print "<" URN "w" windex[word] ">", TYPE,          WORD,                         ".";
                    print "<" URN "w" windex[word] ">", LABEL,         "\"" word "\"",               ".";
                    print "<" URN "f" windex[word] ">", TYPE,          FORM,                         ".";
                    print "<" URN "f" windex[word] ">", LABEL,         "\"" word "\"",               ".";
                    print "<" URN "f" windex[word] ">", WRITTENREP,    "\"" word "\"",               ".";
                    print "<" URN "w" windex[word] ">", CANONICALFORM, "<" URN "f" windex[word] ">", ".";
                }

                print "<" URN "s" sindex[isa] ">",  TYPE,      LEXICALSENSE,                 ".";
                print "<" URN "s" sindex[isa] ">",  LABEL,     "\"" isa "\"",                ".";
                print "<" URN "s" sindex[isa] ">",  ISSENSEOF, "<" URN "w" windex[word] ">", ".";
                print "<" URN "w" windex[word] ">", SENSE,     "<" URN "s" sindex[isa] ">",  ".";
            }

            print "<" URN "s" sindex[sense] ">", BROADER,  "<" URN "s" sindex[isa] ">",   ".";
            print "<" URN "s" sindex[isa] ">",   NARROWER, "<" URN "s" sindex[sense] ">", ".";
        }
    }
}
