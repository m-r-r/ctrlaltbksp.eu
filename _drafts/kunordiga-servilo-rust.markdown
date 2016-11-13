---
layout: post
title: Mi skribas kunordigan servilon en Rust
language: eo
# superskripojn: sed 's/\(u\)x/\1\xcc\x86/gi;s/\([cghjs]\)x/\1\xcc\x82/gi' | uconv -x Any-NFC
---

[Rust] estas <q>sistema programlingvo, kiu estas tre rapida, antaŭmalhelpas memorajn erarojn kaj garantias sekurecon inter fadenoj</q>.

Ekde la versio 0.8, mi tre interesiĝas pri tiu progamlingvo, kaj mi decidis uzi ĝin por skribi BitTorentan kunordigan servilon.

## Funkciado de BitTorrent

[BitTorrent][bt] estas samtavola dosierdisŝuta protokolo. Ĝi estas detale priskribita en la [BEP003].

### Samtavola ŝutado

En BitTorenta reto, datumo estas dividita en pecojn, kiujn estas divastigitaj inter samtavolanoj :

- Kiam samtavolano aliĝas al la reto, ĝi ankoraŭ ne alŝutis la dosierojn.
- La samtavolano petas datumpecojn al samtavolanjo, kiuj jam alŝutis la dosierojn. Tiel,
  ĝi alŝutas la dosierojn pecon post pecon el la aliaj samtavolanoj.
- Elŝutinte datumpecon, la samtavolano tuj povas elŝuti ĝin al aliaj samtavolanoj, kiuj petas ĝin.

Do, por aliĝi BitTorentan reton, samtavolano devas havi la IP-adresojn de la aliaj samtavolanoj. 
Ili povas obteni tiu informo per diversaj manieroj: [DHT], [PEX]... aŭ kunordiga servilo.

### La kunordiga protokolo

La protokolo uzata inter la samtavolanoj kaj la kunordiga servilo estas relative simpla:

1. Kiam samtavolanto ekelŝutas torenton, ĝi sendas *anoncon* al la kunordiga
   servilo. La *anonco* simple estas HTTP-peto kiu enhavas diversajn informojn
   uzatajn de la servilo por trovi aliajn samtavolanojn.  
   Tiuj informoj inkluzivas la identigilon de la torenton, la IP-adresso de la
   samtavolano, ktp. (Mi skribos pri tio pli detale en venonta artikolo.)
2. La kunordiga servilo aldonas la samtavolanon al sia listo de samtavolanoj,
   kaj sendas respondon al la samtavolano.  
   La respondo enhavas la liston de samtavolanoj kaj tempolimon.
3. La samtavolano havas la liston, do ĝi povas peti datumpecojn al la aliaj
   samtavolanoj. Post la tempolimo estos pasinta, la samtavolano petos novan
   liston al la kunordiga servilo.

### Bencode

Bencode

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