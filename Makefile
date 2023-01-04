.PHONY: dev build deploy create
.DEFAULT_GOAL := build

dev:
	hugo server -D

build:
	hugo
	git add -A
	git commit -am "Hugo build"

deploy:
	git push -u origin main

create:
	hugo new posts/$(slug)/index.md
