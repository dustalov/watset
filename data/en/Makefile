export LANG:=en_US.UTF-8
export LC_COLLATE:=C
export LC_CTYPE:=C

all: raw graph gold

raw: enwiktionary.tsv

enwiktionary.tsv:

graph: raw
	@echo "# Generating the word graph."
	./edges.sh

gold:

clean:
	rm -fv *.txt *.tsv
