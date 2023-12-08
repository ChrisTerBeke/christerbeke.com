.PHONY: all

all: build deploy

dev:
	hugo server -D

build:
	hugo
	git add -A
	git commit -am "Hugo build"

deploy:
	git push

create:
	hugo new posts/$(slug)/index.md
