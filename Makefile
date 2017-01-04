export LANG:=en_US.UTF-8

.PHONY: data

data:
	$(MAKE) -C data all
