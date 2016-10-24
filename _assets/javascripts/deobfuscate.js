;(function() {
    "use strict";
    window.addEventListener("load", function() {
        var elements = document.getElementsByClassName("obfurscated");

        for (var i=0; i < elements.length; i++) {
            var element = elements[i];
            var inner = element.getAttribute('data-inner');
            var span = document.createElement('span');

            element.innerHTML = decode(inner);
            element.classList.remove('obfurscated');
        }

        function decode(text) {
            var result="",
                chars=text.split('0x');

            for (var c=0; c < chars.length; c++) {
                result += String.fromCharCode(parseInt(chars[c], 16));
            }

            return result;
        }
    }, false);
})();
