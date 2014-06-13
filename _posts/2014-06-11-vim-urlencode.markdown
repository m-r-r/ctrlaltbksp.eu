---
# vim: set lbr tw=80 spell spelllang=fr:
layout: post
title:  "Encoder des URLs avec VIM"
date: 2014-06-11 14:46:52
lang: fr
tags:
    - VIM
    - URL
published: true
---

VIM est un éditeur de texte très puissant qui dispose d'un langage de script
basique, le VimL.  
En écrivant un plugin pour cet éditeur, j'ai eu besoin d'encoder des fragments
d'URL. Bien entendu, la fonction `encodeURIComponent` n'existe pas en VimL, j'ai
donc dû la créer.    

# La fonction `encodeURIComponent`

La fonction `encodeURIComponent` est une fonction JavaScript qui est utilisée
pour encoder des caractères spéciaux dans les URLs.

La fonction ne change pas les caractères alphanumériques, mais replace les
caractères <q>interdits</q> (<code>+</code>, <code>=</code>, etc...) ou
accentués par leur valeur numérique précédée par le symbole <code>%</code>.

```js
encodeURIComponent("");
//=> ""

encodeURIComponent("aBc2");
//=> "aBc2"

encodeURIComponent("/");
//=> "%2F"

encodeURIComponent("+");
//=> "%2B"

encodeURIComponent("2 + 2 = 4");
//=> "2%20%2B%202%20%3D%204"
```

Dans l'exemple ci-dessus, le symbole `/` est remplacé par `%2F` car
<var>0x2F</var> (ou 47, en décimal) est le numéro du caractère `/` dans la
table ASCII. Le caractère ` ` (espace) est lui remplacé par `%20`, puisque
<var>0x20</var> (32, en décimal) corresponds à l'espace dans la table ASCII.

C'est de cette fonction que j'ai besoin dans mon script, je vais donc essayer de
la traduire en langage de script VIM.

# Portage en langage VIM

La fonction `encodeURIComponent` prend en argument une chaîne de
caractères, et retourne une autre chaine de caractère.  
En VimL, cela donne le code suivant: 

```vim
function! s:encodeURIComponent(str) abort
    " TODO: encoder la chaîne
    return a:str
endfunction

echo s:encodeURIComponent("test: +/=")
" Devrait afficher 'test:%20%2B%2F%3D'
```

Si l'on enregistre ce code dans un fichier `test.vim` ouvert avec VIM,
et que l'on entre ensuite la commande `:so %`; le code devrait s'exécuter.

## Trouver les caractères <q>interdits</q>

Pour encoder les caractères non alphanumérique, il vas falloir commencer par les
trouver. Pour ça, le plus simple est sans doute de séparer la fonction en deux:
une fonction qui exécute l'encodage, et une autre qui cherche les caractères à
encoder et appelle la première.

```vim
function! s:encodeURIChars(str) abort
    " TODO: encoder la chaîne
    return a:str
endfunction

" Appelle 's:encodeURIChars' sur les caractères non-alphanumeriques
function! s:encodeURIComponent(str) abort
    return substitute(a:str, '\W\+',
        \'\=s:encodeURIChars(submatch(0))', 'gcm')
endfunction

echo s:encodeURIComponent("test: +/=")
" Devrait afficher 'test%3A%20%2B%2F%3D'
```

La fonction `substitute()` permets d'effectuer une opération <q>chercher /
remplacer</q> dans une chaîne de caractères. Lorsque son troisième argument
est le nom d'une fonction précédée par `\=`, le motif à chercher est remplacé
par le résultat de cette fonction. Cette ligne appellera donc le fonction
`s:encodeURIChars` sur chaque groupe de caractères non alphanumérique de la
chaîne reçue en argument. 

## Encoder les caractères

Pour encoder les caractères trouvés, il suffit de parcourir la chaîne en
remplaçant chaque nombre par son numéro en hexadécimal dans la table ASCII
précédé par un `%`.

L'instruction `foreach` n'existe pas en VimL, mais une boucle `while` fera
l'affaire.

VIM possède une fonction `char2nr()`, qui renvoie le numéro du caractère passé
en argument dans la table ASCII. L'expression `echo char2nr('A')` affichera
par exemple <samp>65</samp>.

Enfin, il est possible de formater un nombre en hexadécimal à l'aide de la
fonction `printf()`. 

Au final, le code deviens donc:

```vim
function! s:encodeURIChars(str) abort
    let result = ''
    let pos = 0
    while pos < strchars(a:str)
        let result .= printf('%%%02X', char2nr(a:str[pos]))
        let pos += 1
    endwhile
    return result
endfunction

" Appelle 's:encodeURIChars' sur les caractères non-alphanumeriques
function! s:encodeURIComponent(str) abort
    return substitute(a:str, '\W\+',
        \'\=s:encodeURIChars(submatch(0))', 'gcm')
endfunction

echo s:encodeURIComponent("test: +/=")
" Devrait afficher 'test%3A%20%2B%2F%3D'
```

Le premier argument de la fonction `printf()` décrit le format de la chaîne de
caractères que `printf()` retourne. Ici, `%02X` veut dire <q>un nombre décimal
en majuscules, long de deux digits minimum</q>, et le `%%` sert à ajouter le
symbole `%` devant ce nombre.  
Les chaîne retournées par `printf` sont ensuite concaténées ensemble avant d'être renvoyée par la fonction.

Bien entendu, utiliser la fonction `printf()` dans une boucle est loin d'être
une solution optimale: la fonction est connue pour être lente, car elle perds
du temps à décoder sa chaîne de formatage à chaque appel et qu'elle est
variadique. Cependant, le langage de VIM ne semble pas disposer d'autre
fonctions capables de convertir un nombre en une chaine de caractères
hexadécimaux.

Au final, si l'on lance le script, il affiche bien ce qu'il est censé afficher:

    test:%20%2B%2F%3D


## Gestion des caractères multi-octets

Le code semble fonctionner. Cependant, si l'on appelle la fonction avec en
paramètre une chaîne encodée en UTF-8, on s'aperçoit que ce n'est pas le cas:

```vim
echo s:encodeURIComponent("Ĥěľľö Ẁøṟḻď")
```

Le code ci-dessus affiche le texte
<code>%C4%A4%C4%9B%C4%BE%C4%BE%C3%B6%C2</code>, alors que la version JavaScript
affiche le texte suivant:

    %C4%A4%C4%9B%C4%BE%C4%BE%C3%B6%C2%A0%E1%BA%80%C3%B8%E1%B9%9F%E1%B8%BB%C4%8F

En fait, cela viens de l'utilisation de la fonction `strchars()` par le script:
le fonction `strchars()` renvoie le nombre de *caractères* contenus dans le
chaîne.

L'UTF-8 est un jeu de caractères multi-octets: les caractères spéciaux tiennent
souvent sur plusieurs octets, alors que les caractères alphanumériques tiennent
sur un seul octet. L'expression `strchars("é")` renverra <samp>1</samp>, par
exemple, alors que le caractère <q>é</q> (U+00E9) tiens sur 2 octets.

Pour encoder un caractère multi-octets dans une URL, on doit en fait encoder
séparément chaque octet qui compose le caractère. La fonction à utiliser pour
obtenir la taille de la chaîne est donc `strlen()`, qui ne tiens pas compte du
jeu de caractères.

La fonction `s:encodeURIChars` deviens donc:

```vim
function! s:encodeURIChars(str) abort
    let result = ''
    let pos = 0
    while pos < strlen(a:str)
        let result .= printf('%%%02X', char2nr(a:str[pos]))
        let pos += 1
    endwhile
    return result
endfunction
```

# Version finale

Voilà la version finale du code:

```vim
function! s:encodeURIChars(str) abort
    let result = ''
    let pos = 0
    while pos < strlen(a:str)
        let result .= printf('%%%02X', char2nr(a:str[pos]))
        let pos += 1
    endwhile
    return result
endfunction

" Appelle 's:encodeURIChars' sur les caractères non-alphanumeriques
function! s:encodeURIComponent(str) abort
    return substitute(a:str, '\W\+',
        \'\=s:encodeURIChars(submatch(0))', 'gcm')
endfunction
```
