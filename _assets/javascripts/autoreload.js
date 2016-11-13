(function() {
  "use strict";
  var qs = document.location.search;
  if (!/autoreload=1/.test(qs)) {
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

  function check() {
    var r = new XMLHttpRequest();
    var url = document.location.href + ((qs && qs !== '') ? '&' : '?') + 'r=' + Math.random();
    r.open('HEAD', url, true);
    r.onreadystatechange = function() {
      if (r.readyState == 4) {
        var found_etag = r.getResponseHeader('Etag').replace(/^"|"$/g);
        //console.log('current_etag:', current_etag, 'found_etag:', found_etag);
        if (current_etag === null) {
          current_etag = found_etag;
        }
        else if (found_etag !== current_etag) {
          document.location.search =
            '?etag=' + encodeURIComponent(found_etag) +
            '&scrolly=' + (window.scrollY || window.pageYOffset) +
            '&autoreload=1';
          return;
        }
        setTimeout(check, 1500);
      }
    };
    r.send(null);
  }
  check();
})();
