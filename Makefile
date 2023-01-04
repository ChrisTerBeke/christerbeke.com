.PHONY: dev build create

dev:
	hugo server -D

build:
	hugo
	git add -A
	git commit -am "Hugo build"

create:
	hugo new posts/$(slug)/index.md
