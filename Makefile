.PHONY: build install utils

build:
	make install
	make utils

install:
	DIR=install bash index.sh

utils:
	DIR=utils bash index.sh
