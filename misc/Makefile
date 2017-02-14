export LANG:=en_US.UTF-8
export LC_COLLATE:=C
export SHELL:=/bin/bash

all: patterns wiktionary mas ruthes joint

joint: patterns wiktionary mas
	cat {patterns-limit,wiktionary,mas}-isas.txt >joint-isas.txt

expand: patterns wiktionary mas
	./expand.sh {patterns-limit,wiktionary,mas}-isas.txt
	cat {patterns-limit,wiktionary,mas}-exp-isas.txt >joint-exp-isas.txt

patterns: ru-librusec-wiki-diff.csv.gz
	zcat ru-librusec-wiki-diff.csv.gz | tail -n+2 | tr ' ' '_' | sort --parallel=$$(nproc) -t$$'\t' -S1G -k3,3nr -k1,1 -s >patterns-isas.txt
	awk -F'\t' '$$3>=30' patterns-isas.txt | cut -f1,2 > patterns-limit-isas.txt

ru-librusec-wiki-diff.csv.gz:
	curl -sLO 'http://panchenko.me/data/joint/isas/ru-librusec-wiki-diff.csv.gz'

wiktionary:
	@echo "# Assuming that you have Wiktionary as ${CURDIR}/../data/ru/ruwiktionary.tsv."
	../data/wiktionary.awk -v RELATION=HYPERNYM ../data/ru/ruwiktionary.tsv >wiktionary-isas.txt

mas:
	@echo "# Assuming that you have MAS as is-a-rel_MAS.txt."
	./mas-isas.awk is-a-rel_MAS.txt >mas-isas.txt

ruthes:
	@echo "# Assuming that you have processed RuThes as ${CURDIR}/../data/ru/ruthes.xml."
	xsltproc ruthes-isas.xsl ../data/ru/ruthes.xml >ruthes-isas.txt

freqrnc2012.csv:
	curl -sLO 'https://hsemysql.wikispaces.com/file/view/freqrnc2012.csv/404746392/freqrnc2012.csv'

clean:
	rm -fv ru-librusec-wiki-diff.csv.gz freqrnc2012.csv
	rm -fv *-exp.txt *-isas.txt *-linked.tsv
