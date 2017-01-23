export LANG:=en_US.UTF-8
export LC_COLLATE:=C
export LC_CTYPE:=C

.PHONY: data impl eval

all: impl eval

data-ru:
	$(MAKE) -C data ru

data-en:
	$(MAKE) -C data en

impl:
	$(MAKE) -C impl all

eval:
	$(MAKE) -C eval all

clean:
	$(MAKE) -C data clean
	$(MAKE) -C impl clean
	$(MAKE) -C eval clean
