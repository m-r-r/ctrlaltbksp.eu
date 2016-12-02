(function() {
  "use strict";
  var qs = document.location.search;
  var main = document.querySelector('main');
  if (!main || !/autoreload=1/.test(qs)) {
    return;
  }
  var current_etag = qs.match(/etag=("?[a-zA-Z0-9_-]+)/);
  if (current_etag !== null) {
    current_etag = current_etag[1];
  }
  var scrolly = qs.match(/scrolly=([0-9]+)/);
  if (scrolly) {
    scrolly = parseInt(scrolly[1]);
    window.scrollTo(window.scrollX, scrolly);
    setTimeout(function() {
      window.scrollTo(window.scrollX, scrolly);
    }, 10);
  }
  
  const parser = new DOMParser();

  function check() {
    var r = new XMLHttpRequest();
    var url = document.location.href;
    r.open('GET', url, true);
    r.onreadystatechange = function() {
      if (r.readyState == 4) {
        var found_etag = r.getResponseHeader('Etag').replace(/^"|"$/g);
        //console.log('current_etag:', current_etag, 'found_etag:', found_etag);
        if (current_etag === null || found_etag !== current_etag) {
          try {
            var doc = parser.parseFromString(r.responseText, 'text/html');
            var docMain = doc.querySelector('main');
            main.parentNode.replaceChild(docMain, main);
            main = docMain;
          } catch (err) {
            console.error(err);
            main = document.querySelector('main');
          }
        }
        current_etag = found_etag;
        setTimeout(check, 1500);
      }
    };
    r.send(null);
  }
  check();
})();
