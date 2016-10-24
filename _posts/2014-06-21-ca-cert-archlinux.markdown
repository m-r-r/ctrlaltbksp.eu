---
# vim: set lbr tw=80 spell spelllang=fr:
layout: post
title:  "Installer le certificat TLS de CAcert.org sous ArchLinux"
date: 2014-06-21 17:25:51 +0200
language: fr
tags:
    - GNU/Linux
    - ArchLinux
    - TLS
    - CAcert.org
published: true
---

<em lang="eo" title="Salut !">Saluton !</em>

Aujourd'hui, je suis tombé sur un problème assez embêtant:

<figure>
<img alt="Navigateur Web affichant un message d'erreur à propos de certificats TLS non valides" src="/files/dwb-tls-ca-error.png" />
<figcaption>Capture d'écran de mon navigateur web</figcaption>
</figure>

Mon navigateur Web m'affichait une page d'erreur chaque fois ou presque que
j'essayais d'accéder à un site en [HTTPS][wiki-https].  
Le plus bizzare était que l'erreur survenait sur certains sites 
([toile-libre.org][tl] et [linuxfr.org][dlfp], notamment), mais pas sur
d'autres...

Au bout d'un moment, j'ai finis par comprendre: les certificats de
ces sites étaient tous signés par [CAcert.org][ca-cert], et le certificat
racine de CAcert n'était pas installé sur ma machine.

Pour rappel, les sites utilisant HTTPS possèdent un certificat [TLS][wiki-tls]
qui a normalement été délivré par une autoritée de certification. Cette autorité
de certification (dans le cas présent CAcert.org) possède elle aussi un
certificat, qui doit être installé sur la machine cliente.

Généralement, les certificats TLS des autorités de certification les plus
courantes sont installés avec le système d'exploitation.  
Ce n'est malheureusement pas toujours le cas de CAcert.org, qui est une
autorité de certification indépendante assez peu utilisée.  

Sur [ArchLinux][arch] (le système d'exploitation que j'utilise), il faut donc
l'installer manuellement depuis [AUR][aur]:

    $ sudo yaourt -S cacert-dot-org

Il faut ensuite quitter le navigateur Web (ou n'importe quelle autre application
utilisant TLS) et le rouvrir: tout devrait fonctionner correctement :-)



[wiki-https]:   http://fr.wikipedia.org/wiki/HTTPS
                "HyperText Transport Protocol Secure — Wikipédia"
[wiki-tls]:     https://fr.wikipedia.org/wiki/Transport_Layer_Security
                "Transport Layer Security — Wikipédia"
[dlfp]:         http://linuxfr.org
                "LinuxFr.org"
[tl]:           http://toile-libre.org
                "Toile Libre | Hébergement libre pour une toile libre !"
[arch]:         https://www.archlinux.org/
                "Arch Linux"
[aur]:          https://aur.archlinux.org/
                "AUR (en) - Home"
[ca-cert]:      http://www.cacert.org/
                "Welcome to CAcert.org"
