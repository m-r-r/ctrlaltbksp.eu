all:	_site

serve:
	bundle exec jekyll serve -w --config _config.yml,_dev.yml

_site:	.
	JEKYLL_ENV=production bundle exec jekyll build 

pull-tinytypo:
	git subtree pull --prefix _assets/stylesheets/tinytypo https://github.com/tetue/tinytypo.git master --squash
