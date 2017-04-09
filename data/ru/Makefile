export LANG:=en_US.UTF-8
export LC_COLLATE:=C
export SHELL:=/bin/bash

all: raw graph gold

raw: ruwiktionary.tsv abramov.dat unldc.tsv

ruwiktionary.tsv:
	curl -sL 'http://depot.nlpub.ru/wiktionary/ruwiktionary-20170201.tsv' -o 'ruwiktionary.tsv'

abramov.dat:
	@echo "# Downloading the Abramov's dictionary."
	curl -sLO 'http://downloads.sourceforge.net/project/aoo-extensions/3233/3/dict_ru_ru-0.3.7.oxt'
	unzip -p dict_ru_ru-0.3.7.oxt th_ru_RU_v2.dat >abramov.dat

unldc.tsv:
	@echo "# Downloading the UNLDC synsets."
	curl -sL 'https://github.com/dikonov/Universal-Dictionary-of-Concepts/raw/master/data/misc/russian-synsets.csv' -o unldc.tsv

graph: raw
	@echo "# Generating the word graph."
	./edges.sh

gold: ruthes yarn

ruthes: ruthes.xml
	xsltproc ruthes.xsl ruthes.xml | ./ruthes-synsets.awk >ruthes-synsets.tsv
	../../pairs.awk ruthes-synsets.tsv >ruthes-pairs.txt

ruthes.xml:
	@echo "# Assuming that you have RuThes in the directory ${CURDIR}/ruthes-v2."
	./ruthes-stub.awk ruthes-v2/*.xml >ruthes.xml

rwn: rwn.xml
	xsltproc rwn.xsl rwn.xml | ./ruthes-synsets.awk >rwn-synsets.tsv
	../../pairs.awk rwn-synsets.tsv >rwn-pairs.txt

rwn.xml:
	@echo "# Assuming that you have RuWordNet in the directory ${CURDIR}/rwn-xml."
	./ruthes-stub.awk -v TAG=rwn rwn-xml/*.*.xml >rwn.xml

yarn: yarn.xml
	xsltproc yarn.xsl yarn.xml | ./yarn-synsets.awk -v V=8 >yarn-synsets.tsv
	../../pairs.awk yarn-synsets.tsv >yarn-pairs.txt

yarn.xml:
	@echo "# Downloading the YARN dump."
	curl -sLO https://russianword.net/yarn.xml

clean:
	rm -fv dict_ru_ru-0.3.7.oxt
	rm -fv *.txt *.tsv *.csv *.dat *.xml
