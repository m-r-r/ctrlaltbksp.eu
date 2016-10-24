---
layout: page
language: fr
featured: 4
title: Bookmarklets
---

# Recharger le CSS

Recharge les feuilles de styles CSS de la page en ajoutant le timestamp en paramètre à la fin de l'URL.  
Ne fonctionne que sur les navigateurs récents (FF 47, Chrome 49, Edge 13, Safari 10, Opera 40, etc.).

```javascript
(function () {
  var elements = Array.from(document.querySelectorAll('link[rel=stylesheet][href]'));
  elements.forEach((element) => {
    var href = element.href.replace(/[?&]t=([^&$]*)/,'');
    element.href = href + (href.indexOf('?') !== -1 ? '&' : '?') + 't=' + (new Date().getTime());
  });
})();
```

# Supprimer les images

Supprime toutes les images (balises `<img />`) de la page.

```javascript
(function () {
  Array.prototype.forEach.call(
    document.querySelectorAll('img'),
    function (node) {
      node.parentNode.removeChild(node);
    }
  );
})();
```

# Adresses des vidéos

Affiche les adresses des vidéos présentes sur la page dans la console du navigateur.  
Ne fonctionne pas sur les sites qui téléchargent la vidéo dans une mémoire tampon (Youtube).

```javascript
(function () {
  Array.prototype.reduce.call(
    document.querySelectorAll('video'),
    function (acc, video) {
      console.debug(video.currentSrc);
      return true;
    },
    false
  ) || console.debug("Aucune vidéo trouvée sur cette page");
})();
```

# Vider le <code>localStorage</code>

```javascript
(function () {
  Object.keys(window.localStorage).forEach(function (key) {
    delete window.localStorage[key];
  }) && console.debug("Le localStorage à été vidé");
})();
```

<script type="text/javascript">
	window.addEventListener("load", function () {
	  "use strict";
  	var bookmarklets = document.querySelectorAll('main .language-javascript.highlighter-rouge');
  	
    var titleRe = /^h[1-6]$/i;
  	
  	Array.prototype.forEach.call(bookmarklets, function (bookmarklet) {
  		var title = findTitle(bookmarklet);
  		if (!title || !title.innerText || !bookmarklet.innerText) {
  		  return;
  		}
  		
  		var link = document.createElement('a');
  		link.setAttribute('rel', 'bookmark');
  		link.setAttribute('href', 'javascript:void ' + encodeURIComponent(uglify(bookmarklet.innerText)));
  		link.appendChild(document.createTextNode(title.innerText));
  		
  		var paragraph = document.createElement('p');
  		paragraph.appendChild(link);
  		if (bookmarklet.nextSibling) {
  			bookmarklet.parentNode.insertBefore(paragraph, bookmarklet.nextSibling);
  		} else {
  			bookmarklet.parentNode.appendChild(paragraph);
  		}
  	});
  	
  	function findTitle (element) {
      while (true) {
        if (titleRe.test(element.tagName)) {
          return element;
        } else if (element.previousElementSibling) {
          element = element.previousElementSibling;
        } else {
          return null
        }
      }
    }

    function uglify (js) {
      return js
        .replace(/function\s*\(\s*([^)]*)\s*\)\s*{/g, 'function($1){')
        .replace(/([;,(){}]?)\s*$\s*(\S)/mg, '$1$2')
        .replace(/;\s*$/, '')
      ;
    }
	});
</script>