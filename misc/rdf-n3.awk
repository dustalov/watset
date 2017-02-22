#!/usr/bin/awk -f
BEGIN {
    FS = "\t";

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

    if (nsenses == 0 || nisas == 0) next;

    print "<urn:linked:c" $1 ">", TYPE,  CONCEPT,           ".";
    print "<urn:linked:c" $1 ">", LABEL, "\"synset" $1 "\"", ".";

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

                print "<urn:linked:w" windex[word] ">", TYPE,          WORD,                             ".";
                print "<urn:linked:w" windex[word] ">", LABEL,         "\"" word "\"",                   ".";
                print "<urn:linked:f" windex[word] ">", TYPE,          FORM,                             ".";
                print "<urn:linked:f" windex[word] ">", LABEL,         "\"" word "\"",                   ".";
                print "<urn:linked:f" windex[word] ">", WRITTENREP,    "\"" word "\"",                   ".";
                print "<urn:linked:w" windex[word] ">", CANONICALFORM, "<urn:linked:f" windex[word] ">", ".";
            }

            print "<urn:linked:s" sindex[sense] ">", TYPE,          LEXICALSENSE,       ".";
            print "<urn:linked:s" sindex[sense] ">", LABEL,         "\"" sense "\"",    ".";
            print "<urn:linked:s" sindex[sense] ">", ISSENSEOF,     "<urn:linked:w" windex[word] ">",  ".";
            print "<urn:linked:w" windex[word] ">",  SENSE,         "<urn:linked:s" sindex[sense] ">", ".";
            print "<urn:linked:s" sindex[sense] ">", REFERENCE,     "<urn:linked:c" $1 ">",            ".";
            print "<urn:linked:c" $1 ">",            ISREFERENCEOF, "<urn:linked:s" sindex[sense] ">", ".";
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

                    print "<urn:linked:w" windex[word] ">", TYPE,          WORD,              ".";
                    print "<urn:linked:w" windex[word] ">", LABEL,         "\"" word "\"",    ".";
                    print "<urn:linked:f" windex[word] ">", TYPE,          FORM,              ".";
                    print "<urn:linked:f" windex[word] ">", LABEL,         "\"" word "\"",    ".";
                    print "<urn:linked:f" windex[word] ">", WRITTENREP,    "\"" word "\"",    ".";
                    print "<urn:linked:w" windex[word] ">", CANONICALFORM, "<urn:linked:f" windex[word] ">", ".";
                }

                print "<urn:linked:s" sindex[isa] ">",  TYPE,      LEXICALSENSE,      ".";
                print "<urn:linked:s" sindex[isa] ">",  LABEL,     "\"" isa "\"",     ".";
                print "<urn:linked:s" sindex[isa] ">",  ISSENSEOF, "<urn:linked:w" windex[word] ">", ".";
                print "<urn:linked:w" windex[word] ">", SENSE,     "<urn:linked:s" sindex[isa] ">",  ".";
            }

            print "<urn:linked:s" sindex[sense] ">", BROADER,  "<urn:linked:s" sindex[isa] ">",   ".";
            print "<urn:linked:s" sindex[isa] ">",   NARROWER, "<urn:linked:s" sindex[sense] ">", ".";
        }
    }
}
