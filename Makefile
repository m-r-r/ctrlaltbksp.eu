IP ?= 0.0.0.0
PORT ?= 8000

all:	_site

serve:
	bundle exec jekyll serve --watch --host $(IP) --port $(PORT) $(JEKYLLOPTS)

_site:	.
	JEKYLL_ENV=production bundle exec jekyll build 

pull-tinytypo:
	git subtree pull --prefix _assets/stylesheets/tinytypo https://github.com/tetue/tinytypo.git master --squash

