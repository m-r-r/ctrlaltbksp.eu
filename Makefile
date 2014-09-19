all:	_site

ftp_upload:	_site
	cd _site \
		&& lftp -e 'mirror -Rne; exit' mrr@ftp.toile-libre.org:/devrandom/ctrlaltbksp.eu-web/htdocs

scp_upload:	_site
	cd _site \
		&& lftp -e 'mirror -Rne; exit' sftp://2173857@sftp.dc0.gpaas.net/lamp0/web/vhosts/ctrlaltbksp.eu/htdocs

serve:
	jekyll serve -w --config _config.yml,_dev.yml

_site:	.
	jekyll build

