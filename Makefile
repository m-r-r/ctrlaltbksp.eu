all:	_site

serve:
	bundle exec jekyll serve -w --config _config.yml,_dev.yml

_site:	.
	JEKYLL_ENV=production bundle exec jekyll build 

