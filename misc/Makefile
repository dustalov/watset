export LANG:=en_US.UTF-8
export LC_COLLATE:=C

all: patterns wiktionary mas ruthes

patterns: ru-librusec-wiki-diff.csv.gz
	zcat ru-librusec-wiki-diff.csv.gz | tail -n+2 | sort --parallel=$$(nproc) -t$$'\t' -S1G -k3nr >patterns-isas.txt

ru-librusec-wiki-diff.csv.gz:
	curl -sLO 'http://panchenko.me/data/joint/isas/ru-librusec-wiki-diff.csv.gz'

wiktionary:
	@echo "# Assuming that you have the Wiktionary as wiktionary.tsv."
	./wiktionary-isas.awk wiktionary.tsv >wiktionary-isas.txt

mas:
	@echo "# Assuming that you have MAS as is-a-rel_MAS.txt."
	./mas-isas.awk is-a-rel_MAS.txt >mas-isas.txt

ruthes:
	@echo "# Assuming that you have processed RuThes as ${CURDIR}/../data/ru/ruthes.xml."
	xsltproc ruthes-isas.xsl ../data/ru/ruthes.xml >ruthes-isas.txt

clean:
	rm -fv ru-librusec-wiki-diff.csv.gz
	rm -fv *-isas.txt

# ./expand.py --w2v=all.norm-sz500-w10-cb0-it3-min5.w2v --kmeans=sz500-k20-l1.0/kmeans.pickle --path=sz500-k20-l1.0 --model=regularized_synonym patterns-isas.txt >patterns-exp-isas.txt
