export LANG:=en_US.UTF-8

all: raw graph gold

raw: wiktionary.tsv abramov.dat unldc.tsv

wiktionary.tsv:
	@echo "# Downloading the Russian Wiktionary."
	curl -s 'http://ustalov.imm.uran.ru/pub/projlearn-ruwikt.tar.gz' | tar -xOzf - projlearn-ruwikt/all_ru_pairs_ruwikt20160210_parsed.txt >wiktionary.tsv

abramov.dat:
	@echo "# Downloading the Abramov's dictionary."
	curl -sLO 'http://downloads.sourceforge.net/project/aoo-extensions/3233/3/dict_ru_ru-0.3.7.oxt'
	unzip -p dict_ru_ru-0.3.7.oxt th_ru_RU_v2.dat >abramov.dat

unldc.tsv:
	@echo "# Downloading the UNLDC synsets."
	curl -sL 'https://github.com/dikonov/Universal-Dictionary-of-Concepts/raw/master/data/misc/russian-synsets.csv' -o unldc.tsv

graph:
	@echo "# Generating the word graph."
	./edges.sh

gold: ruthes yarn

ruthes:
	@gem list -i nokogiri >/dev/null 2>&1 || echo "# Please do 'gem install nokogiri' to work with RuThes."
	@echo "# Assuming that you have RuThes in the directory data/ruthes-v2."
	./ruthes.rb
	sort -uso ruthes-pairs.txt ruthes-pairs.txt

yarn: yarn-synsets.csv
	./yarn-edges.awk yarn-synsets.csv >yarn-edges.txt

yarn-synsets.csv:
	curl -sLO https://russianword.net/yarn-synsets.csv

clean:
	rm -fv wiktionary.tsv dict_ru_ru-0.3.7.oxt abramov.dat unldc.tsv
	rm -fv edges.txt edges.csv
	rm -fv ruthes-clusters.txt ruthes-pairs.txt ruthes-isas.txt
	rm -fv yarn-synsets.csv yarn-edges.txt
