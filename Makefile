.PHONY: build install utils patch

build:
	make install
	make utils

install:
	DIR=install bash index.sh

utils:
	DIR=utils bash index.sh

patch:
	DIR=patch bash index.sh
