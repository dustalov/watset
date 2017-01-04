export LANG:=en_US.UTF-8

.PHONY: data impl eval

all: data impl eval

data:
	$(MAKE) -C data all

impl:
	$(MAKE) -C impl all

eval:
	$(MAKE) -C eval all

clean:
	$(MAKE) -C data clean
	$(MAKE) -C impl clean
	$(MAKE) -C eval clean
