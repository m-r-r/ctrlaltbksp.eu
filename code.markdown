---
layout: page
title: Code
featured: 3
---

Voici quelques projets Open-Source auxquels j'ai participé:

-   [Pelican](http://getpelican.com) est un générateur de site Web statiques
    que j'utilisait il y a quelques années.  
    J'ai envoyé plusieurs patchs aux développeurs, notemment:
    - Corrections de bugs concernant le support de l'Unicode: [#281][pelican-281]
    - Amélioration du système de journalisation: [#248][pelican-284]
    - Ajout d'un plug-in pour générer des Sitemaps: [#468][pelican-468]
    - Correction d'un bug sur les catégories: [#341][pelican-341]
    - Amélioration d'un script permettant de créer un nouveau site: [#236][pelican-236] et [#335][pelican-335].
-   [WMFS](http://wmfs.info) est un gestionnaire de fenêtres pour X11.
    J'ai crée un paquet source pour Debian: [#21][wmfs-21]
-   [GoAccess](https://github.com/allinurl/goaccess/) est un analyseur de logs pour Apache. 
    J'ai corrigé un bug qui faisait crasher le logiciel: [#92][goaccess-92]
-   [Rust](http://rust-lang.org) est un langage de programmation créé par le fondation Mozilla.  
    J'ai corrigé un petit que j'avais trouvé dans le module `std::io`, et qui faisait crasher le programme
    lorsqu'une valeur invalide était passée à une fonction: [#13799][rust-13799].
-   [Wallabag](http://wallabag.org) est une application de lecture différée.  
    J'ai mis à jour la version française: [#680][wallabag-680].


[pelican-281]:    https://github.com/getpelican/pelican/pull/281 "Patch for issue #271 (« Unicode issue in category name »)"
[pelican-284]:    https://github.com/getpelican/pelican/pull/284 "pelican/log.py simplified a bit"
[pelican-468]:    https://github.com/getpelican/pelican/pull/468 "New signal and new plugin"
[pelican-341]:    https://github.com/getpelican/pelican/pull/341 "Trailing slashes removed to avoid category bug"
[pelican-236]:    https://github.com/getpelican/pelican/pull/236 "Removed small errors in pelican-quickstart"
[pelican-335]:    https://github.com/getpelican/pelican/pull/335 "Quickstart templates"
[wmfs-21]:    https://github.com/xorg62/wmfs/pull/12 "Added a debian/ folder"
[goaccess-92]: https://github.com/allinurl/goaccess/pull/92 "Check if `geo_location_data` is not NULL before using it"
[rust-13799]: https://github.com/mozilla/rust/pull/13799  "Added missing values in std::io::standard_error()"
[wallabag-680]:   https://github.com/wallabag/wallabag/pull/680   "French translation update"   
