export LANG:=en_US.UTF-8
export LC_COLLATE:=C

.PHONY: ru en

ru:
	$(MAKE) -C ru all

en:
	$(MAKE) -C en all

clean:
	$(MAKE) -C ru clean
	$(MAKE) -C en clean
	rm -fv *.txt
