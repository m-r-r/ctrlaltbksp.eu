all:	_site

upload:	_site
	cd _site \
		&& lftp -e 'mirror -Rne; exit' mrr@ftp.toile-libre.org:/devrandom/ctrlaltbksp.eu-web/htdocs

_site:	.
	jekyll build --safe


