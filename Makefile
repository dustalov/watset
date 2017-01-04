export LANG:=en_US.UTF-8

.PHONY: data impl

all: data impl

data:
	$(MAKE) -C data all

impl:
	$(MAKE) -C impl all

clean:
	$(MAKE) -C data clean
	$(MAKE) -C impl clean
