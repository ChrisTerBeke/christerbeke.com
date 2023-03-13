.PHONY: all

all: build

dev:
	hugo server -D

build:
	hugo
	git add -A
	git commit -am "Hugo build"
