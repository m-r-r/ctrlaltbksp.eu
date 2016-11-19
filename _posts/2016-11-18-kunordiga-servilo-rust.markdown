---
layout: post
title: Mi skribas kunordigan servilon en Rust
date: 2016-11-18 13:32:02+01:00
language: eo
---

[Rust] estas <q>sistema programlingvo, kiu estas tre rapida, antaŭmalhelpas
memorajn erarojn kaj garantias sekurecon inter fadenoj</q>.

Ekde la versio 0.8, mi tre interesiĝas pri tiu progamlingvo, kaj mi decidis uzi
ĝin por skribi BitTorentan kunordigan servilon. Mi skribos artikolojn pri la
progreso de tiu projekto en tiu blogo.

## Funkciado de BitTorrent

Ĉi tiu artikolo estas la unuan kiun mi skribas pri tiu projekto, do mi klarigu
kio estas kunordiga servilo kaj kion ĝi faras.

### Samtavola ŝutado

[BitTorrent][bt] estas samtavola dosierdisŝuta protokolo.  En BitTorenta reto,
datumo estas dividita en pecojn, kiujn estas divastigitaj inter samtavolanoj:

- Kiam samtavolano ekelŝutas torenton, ĝi konektiĝas al la kunordiga servilo
  por obteni la IP-adrsojn de aliaj samtavolanoj, kiuj estas disŝutante la saman
  torenton.
- La samtavolano petas datumpecojn al samtavolanjo, kiuj jam alŝutis la dosierojn.
  Tiel, ĝi alŝutas la dosierojn pecon post pecon el la aliaj samtavolanoj.
- Regule, la samtavolano sendas informojn pri la progreso de ĝia elŝutado al 
  la kunordiga servilo. 
- Elŝutinte datumpecon, la samtavolano tuj povas elŝuti ĝin al aliaj samtavolanoj,
  kiuj petas ĝin.

Tiel, la kunordiga servilo detanas la liston de samtavolantoj disŝutantaj
torentojn, kaj elbligas al la samtavolanoj obteni la IP-adresojn de unu la aliaj.

Kunordigaj serviloj ne estas la ununura rimedo per kiu samtavolanoj povas trovi
aliaj samtavolanoj: ankaŭ ekzistas interalie [DHT] kaj [PEX].
Tamen, la protokolo uzata inter kunordiga servilo kaj samtavolanoj estas
relative simpla, do tio faros bona ekzerco por lerni la programlingvon Rust.

### La kunordiga protokolo

La protokolo uzata inter la samtavolanoj kaj la kunordiga servilo estas relative simpla:

1. Kiam samtavolanto ekelŝutas torenton, ĝi sendas *anoncon* al la kunordiga
   servilo. La *anonco* simple estas HTTP-peto kiu enhavas diversajn informojn
   uzatajn de la servilo por trovi aliajn samtavolanojn.  
   Tiuj informoj inkluzivas la identigilon de la torenton, la IP-adresson de la
   samtavolano, ktp. (Mi skribos pri tio pli detale en venonta artikolo.)
2. La kunordiga servilo aldonas la samtavolanon al sia listo de samtavolanoj,
   kaj sendas respondon al la samtavolano.  
   La respondo de la servilo estas kodita en formato nomita [Bencode].
   Tiu respondo enhavas tempolimon, kaj la liston de aliaj samtavolanoj.
3. La samtavolano havas la liston, do ĝi povas peti datumpecojn al la aliaj
   samtavolanoj. Post la tempolimo estos pasinta, la samtavolano denove sendos
   anoncon, kaj ricevos novan liston.

Tiu protokolo estas bazita je la HTTP-protokolo, sed bonŝance, Rust havas
plurajn bibliotekojn, kiujn mi povos uzi por skribi HTTP-servilojn:

- [Iron] estas plej fama HTTP-kadrsoftvaro skribita en Rust
- [Hyper] estas biblioteko por skribi HTTP-servilojn, uzata de Iron.

Mi pensas, ke mi uzos [Hyper], pro tio ke ĝi ebliĝas skribi nesinkronajn
HTTP-servilojn, sed se ĝi estas tro malfacila uzebla, mi uzos [Iron] anstataŭ.

Por kodi datumon en la formato [Bencode], mi planas uzi
[la samnoman bibliotekon][crate-bencode]. 

---

En la venonta artikolo, mi komencos konstrui la projekton kaj skribi la kodon :-)

[Rust]: https://www.rust-lang.org
        "The Rust Programming Language"

[bt]: https://eo.wikipedia.org/wiki/BitTorento
      "BitTorento - Vikipedio"

[DHT]: https://en.wikipedia.org/wiki/Distributed_hash_table
      "Distributed hash table - Wikipedia"
      
[PEX]: https://en.wikipedia.org/wiki/Peer_exchange
       "Peer exchange - Wikipedia"

[BEP003]: http://www.bittorrent.org/beps/bep_0003.html
          "The BitTorrent Protocol Specification"

[iron]: https://crates.io/crates/iron
        "iron - Cargo: packages for Rust"
        
[hyper]: https://github.com/hyperium/hyper/tree/tokio
         "hyperium/hyper at tokio"

[Bencode]: https://wiki.theory.org/BitTorrentSpecification#Bencoding
           "BitTorrentSpecification - Theory.org Wiki"

[crate-bencode]:  https://crates.io/crates/bencode
                  "bencode - Cargo: packages for Rust"