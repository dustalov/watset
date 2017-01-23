export LANG:=en_US.UTF-8
export LC_COLLATE:=C
export LC_CTYPE:=C

.PHONY: ru en

ru:
	$(MAKE) -C ru all
	ln -sfT $(CURDIR){/ru,}/edges.txt

en:
	$(MAKE) -C en all
	ln -sfT $(CURDIR){/en,}/edges.txt

clean:
	$(MAKE) -C ru clean
	$(MAKE) -C en clean
	rm -fv *.txt
