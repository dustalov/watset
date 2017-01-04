export LANG:=en_US.UTF-8

.PHONY: data impl

data:
	$(MAKE) -C data all

impl:
	$(MAKE) -C impl all
