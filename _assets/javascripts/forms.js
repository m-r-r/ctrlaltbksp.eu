;(function () {
  "use strict";
  var elements = document.getElementsByTagName('form');
  for (var i=0; i < elements.length; i++) {
    elements[i].addEventListener('submit', handleFormSubmit, false);
  }

  var dateToString = Date.prototype.toISOString || Date.prototype.toString;

  function handleFormSubmit (event) {
    var dateInput = event.target.elements["date"];
    if (!dateInput || dateInput.type !== 'hidden') {
      return;
    }
    dateInput.value = dateToString.call(new Date());
  }
})();