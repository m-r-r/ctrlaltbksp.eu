---
# vim: set lbr tw=75 spell spelllang=fr:
layout: post
title: "Faire un injecteur de dépendances en PHP"
date: 2014-09-14 20:10:15 +02:00
lang: fr
tags:
    - PHP
published: true
sitemap: false
allow_robots: false
---

L'injection de dépendance (ou <q lang="en">Dependency Injection</q>) est un
[<i lang="en">design pattern</i>][dp] qui consiste à déléguer
l'initialisation de certaines parties d'un programme à une classe, pour
simplifier l'ensemble du programme.

Concrètement, un injecteur de dépendances est donc une classe permettant de
définir des services (connexion à la base de données, <i lang="en">
factories</i> …) et de les utiliser: c'est une sorte de <q>conteneur</q> de
services.  
Ce conteneur est initialisé en début de programme. Il est ensuite passé par
référence à toutes les classes ayant besoin de l'un des services qu'il
contiens.

Beaucoup de <i lang="en">frameworks</i> PHP intrègrent un injecteur de
dépendances (notamment [Aura][aura-di] [Zend][zend-di] et [Symfony][sf-di].

Pour bien comprendre comment fonctionne un injecteur de dépendances, je
vous recommande [cet article][need-di], qui explique ce qu'est l'injection
de dépendances avec des exemples.

---

L'injecteur de dépendances est donc responsable de l'initialisation de
chaque service.  

Avec les versions récentes de PHP, il est assez facile de créer un
injecteur de dépendances: on peut en effet utiliser des 
[<i lang="en">closures</i>][closures] (fonctions anonymes) pour
initialiser les différentes parties du programmes. L'injecteur de
dépendances se servira alors de ces fonctions pour instancier les
différents services.

# Création de la classe

Pour commencer, on peut définir une classe comme ci-dessous:

```php
class DependencyInjector
{
    private $callbacks = array();
}
```

Cette classe sera l'injecteur de dépendances, et l'attribut `$callbacks`
contiendra les fonctions anonymes.

# La surcharge de propriétés

Lorsque l'on essaye d'accéder à une propriété d'un objet, PHP se contente en
général de renvoyer une erreur si cet attribut n'existe pas.

On peut constater ceci en exécutant le code suivant:

```php
$di = new DependencyInjector;
echo $di->test;
```

Ce code essaye d'afficher la valeur de la propriété `test` d'une instance
de la classe `DependencyInjector`.

Si l'on essaye de l'exécuter, PHP affichera une erreur `Undefined
property`, puisque la classe `DependencyInjector` que l'on viens de définir
ne possède pas de propriété `test`.

Si l'on ajoute cette propriété, par contre, le code fonctionnera:

```php
class DependencyInjector
{
    private $callbacks = array();
    public $test = 42; // cette fois ci, la propriétée à été définie
}

$di = new DependencyInjector;
echo $di->test; // affichera 42
```

Il existe pourtant une fonctionnalité de PHP *relativement* peu connue
(elle est quand même largement utilisée): [surcharge de
propriétés][surcharge].

Cette technique consiste à ajouter une méthode `__get()` et `__set()` à
notre classe. 

## La méthode `__get()`

Si une classe possède une méthode `__get()`, cette méthode sera appelée
automatiquement par PHP lorsque l'on tentera de lire une propriété
inexistante. Le nom de la propriété sera passé en argument de la méthode.

Voilà ce que deviens le code précédent si l'on y ajoute une méthode
`__get()`:


Pour ajouter des fonctions supplémentaires à l'objet, on utilisera la
[surcharge de propriétés][surcharge]: Notre classe implémentera les méthode
`__set()` et `__get()`, qui sont appelées lorsque l'on tentera d'accéder à
une propriété
inexistante de l'objet.

```php
class DependencyInjector
{
    private $callbacks = array();

    public function __get($name /* nom de la propriété */)
    {
        echo "Tentative d'accès à la propriété inexistante $name.\n";
        return 42; // valeur retournée
    }
}

$di = new DependencyInjector;
echo $di->test;
```

Si l'on exécute ce code, PHP vas s'apercevoir que la propriété `test` à
laquelle on tente d'accéder n'existe pas. Il vas donc regarder si notre
classe possède une méthode `__get()`.

Comme c'est le cas, il vas appeler cette méthode avec en argument le nom de
la propriété. Dans le code ci dessus, la valeur de la variable `$name` sera
donc `"test"`.

Enfin, la valeur de retour de la fonction (ici, `42`) sera lue à la place
de celle de la propriété inexistante.

Ce code produira donc la sortie suivante:

    Tentative d'accès à la propriété inexistante test.
    42

Cette fonctionalité est donc très utile, puisqu'elle permets de
<q>simuler</q> des propriétés: Si l'on utilise la surcharge de propriétés
pour notre injecteur de dépendances, récupérer une dépendance sera aussi
simple que d'accéder à une propriété.

## La méthode `__set()`

Selon le même principe, la méthode `__set()` d'un objet est appelée lorsque
l'on tente d'écrire dans une propriété inexistante. La méthode reçoit cette
fois en arguments le nom et la valeur de la propriété.

Voilà ce que l'on obtiens si l'on ajoute cette méthode à notre classe:

```php
class DependencyInjector
{
    private $callbacks = array();

    public function __get($name)
    {
        return 42; // valeur retournée
    }

    public function __set($name, $value)
    {
        echo "Tentative d'écriture de la valeur $value dans la propriété $name.\n";
    }
}

$di = new DependencyInjector;
$di->propriete_de_test = 2;
```

L'exécution du code produira la sortie suivante:

    Tentative d'écriture de la valeur 2 dans la propriété propriete_de_test.

Comme la propriété à laquelle on essaye d'assigner la valeur `2` n'existe
pas, PHP appelle la méthode `__set()` avec en argument le nom de la
propriété et la valeur.

## Mise en pratique 

L'utilisation de la surcharge est expliquée plus en détail [dans la
documentation de PHP][surcharge]. Vous trouverez aussi [beaucoup d'exemples
d'utilisation][exemples] sur le Web.

Au final, on peut utiliser la surcharge de propriétés pour notre injecteur:
il suffira de modifier la méthode `__set()` pour qu'elle écrive dans notre
tableau `$callbacks`:

```php
class DependencyInjector
{
    private $callbacks = array();

    public function __set($attr, $value)
    {
        if (is_callable($value)) {
            $this->callbacks[$attr] = $value;
        }
        else {
            $this->$attr = $value;
        }
    }
}
```

Lorsque l'on assigne une propriété, la méthode `__set()` vérifiera si la
valeur reçue est une fonction anonyme.

Si c'est le cas, elle stockera la fonction dans le tableau, et la fonction
sera utilisée plus tard par la méthode `__get()`. Si la valeur n'est pas
une fonction, une nouvelle propriété est directement créé, et PHP
n'appellera plus les méthodes `__set()` et `__get()` pour cette propriété
là, puisqu'elle ne sera plus indéfinie.

Il ne reste donc plus qu'à modifier le méthode `__get()`:

```php
class DependencyInjector
{
    private $callbacks = array();

    public function __set($attr, $value)
    {
        if (is_callable($value)) {
            $this->callbacks[$attr] = $value;
        }
        else {
            $this->$attr = $value;
        }
    }

    public function __get($attr)
    {
        // si une fonction existe pour la propriété
        if (isset($this->callbacks[$attr])) {
            $this->$attr = call_user_func($this->callbacks[$attr]); // on l'appelle
            return $this->$attr;
        }
    }
}

$di = new DependencyInjector;

$di->myValue = function() {
    echo "initialisation de la valeur 1\n";
    return 40;
};

$di->myOtherValue = function() use (&$di) {
    echo "initialisation de la valeur 2\n";
    return $di->myValue + 2;
};

echo $di->myOtherValue . "\n";
echo $di->myOtherValue . "\n;
```

La méthode `__get()` vérifie si une fonction correspondante à la propriété
est présente dans le tableau, et si oui; elle l'appelle. La valeur est
ensuite stockée comme propriété de l'objet, pour éviter que la fonction
`__get()` soit appelée plusieurs fois pour la même propriété.

Au final, si on lance le code ci-dessus, on obtiendra la sortie suivante:

    initialisation de la valeur 2
    initialisation de la valeur 1
    42
    42

On peut voir que les deux fonction son bien appelées dans le bon ordre, et
une seule fois.
Au final, le bon résultat est bien affiché: victoire, donc :-)


# Améliorations possibles

Le code ci-dessus fonctionne, mais il possède plusieurs inconvénients: 

- Tout d'abord, les fonctions anonymes ont besoin de capturer une référence
  vers l'instance de l'objet auquel elles appartiennent (c'est le cas de la
  fonction `myOtherValue`, dans l'exemple précédent).  
  Ce serait plus simple de simplement passer la référence à la fonction
  lors de l'appel.
- Ensuite, lorsque la méthode `__get()` crée la propriété en y écrivant la
  valeur de retour de la fonction, la fonction `__set()` est appelée une
  deuxième fois, puisque la propriété n'existe pas encore.  
  Cela peut être problématique si la fonction retourne une autre fonction,
  et c'est en tout cas inutile.

Le premier problème peut être résolu assez simplement:  
Pour passer aux fonctions une référence vers l'injecteur de dépendence, il
suffit d'ajouter un argument à la fonction `call_user_func()`. On peut même
en ajouter un deuxième, pour que l'utilisateur de la classe plusse passer
une autre variable de son choix.

L'appel inutile à la méthode `__set()`, peut être évité grâce à une
particularité de l'interpréteur PHP: les méthodes magiques (`__get()`,
`__set()`, etc …) sont ignorées lorsque l'on accède à une propriété par
référence.

On modifie donc la méthode `__get()` comme ceci :

```php
    public function __get($attr)
    {
        if (null === ($value = &$this->$attr)) {
            return ($value = call_user_func($this->callbacks[$attr], $this));
        }
    }
```

Pour empêcher PHP d'appeler la méthode `__set()`, on crée une référence
vers la propriété inexistante. PHP vas alors créer cette propriété (sans
passer par `__set()`), et l'initialiser à `null` (d'où le test dans la
condition du `if`).

On assigne ensuite la valeur de retour de la fonction à la variable
`$value`. La valeur de retour est alors écrite dans la propriété puisque la
variable est une référence.

# Code final

Au final, on a donc le code suivant:

```php
class DependencyInjector
{
    private $callbacks = array();
    private $data = null;

    public function __construct($data = null)
    {
        $this->data = $data;
    }

    public function __set($attr, $value)
    {
        if (is_callable($value)) {
            $this->callbacks[$attr] = $value;
        }
        else {
            $this->$attr = $value;
        }
    }

    public function __get($attr)
    {
        if (null === ($v = &$this->$attr)) {
            return ($v = call_user_func($this->callbacks[$attr], $this, $this->data));
        }
    }
}
```


Voilà un exemple d'utilisation:

```php
use FastRoute\RouteCollector;
use FastRoute\RouteParser;
use FastRoute\DataGenerator;
use FastRoute\Dispatcher;
use Zend\Db\Adapter\Adapter;

// [...]

class Services extends DependencyInjector
{
    public function __construct($config) {
        parent::__construct($config);

        $this->collector = function($_, $config) {
            return new RouteCollector(
                new RouteParser\Std,
                new DataGenerator\GroupCountBased
            );
        };

        $this->dispatcher = function($sm, $config) {

            $collector = $sm->collector;
            $collector->addRoute('GET',  '/thread/{name}/{page:\d+}{format:.\w+}', 'ShowThread');
            $collector->addRoute('POST', '/thread/{name}/{page:\d+}{format:\.\w+}', 'PostToThread');
            $collector->addRoute('GET',  '/comment/{id:\d+}.{format:\w+}', 'ShowComment');
            $collector->addRoute('POST',  '/comment/edit/{id:\d+}.{format:\w+}', 'EditComment');
            $collector->addRoute('POST',  '/comment/delete/{id:\d+}.{format:\w+}', 'DeleteComment');

            return new Dispatcher\GroupCountBased($collector->getData());
        };

        $this->dbAdapter = function($sm, $config) {

            $config = array_merge(array(
                'driver' => 'Sqlite3',
                'database' => 'db.sqlite',
            ), $config);

            return new Adapter($config);
        };

        $this->dbThreads = function($sm) {
            return new Threads($sm);
        };

        $this->dbComments = function($sm) {
            return new Comments($sm);
        };
    }
}
```

La classe ci-dessus est instanciée une seule fois au début de
l'application. Lorsque l'un des [modèle][mvc] de l'application accède à un
objet contenu par l'injecteur (la propriété `dbComment`, par exemple), tous
les objets dépendants de cet objets sont initialisés récursivement, et le
bon objet est retournée.


[dp]:      https://fr.wikipedia.org/w/index.php?title=Design_pattern
           "Patron de conception — Wikipédia"
[aura-di]: https://packagist.org/packages/aura/di
           "aura/di — Packagist"
[zend-di]: https://packagist.org/packages/zendframework/zend-di
           "zendframework/zend-di — Packagist"
[sf-di]: https://packagist.org/packages/symfony/symfony
           "symfony/symfony — Packagist"
[mvc]: https://en.wikipedia.org/wiki/Model–view–controller
           "Model–view–controller — Wikipedia, the free encyclopedia"
[need-di]: http://fabien.potencier.org/article/12/do-you-need-a-dependency-injection-container
           "Do you need a Dependency Injection Container? — Fabien Potencier"
[closures]: http://php.net/manual/fr/functions.anonymous.php
           "PHP: Fonctions anonymes - Manual"
[surcharge]: http://fr2.php.net/manual/fr/language.oop5.overloading.php
           "PHP: Surcharge magique - Manual"
[exemples]: https://code.ohloh.net/search?s=mdef%3A__get%20mdef%3A__set&fl=PHP
           "Results - Ohloh Code Search"
