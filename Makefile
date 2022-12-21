.PHONY: all

all: build deploy

build:
	hugo
	git add -A
	git commit -am "Hugo build"

deploy:
	git push -u origin main
