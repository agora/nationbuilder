// Íslenska
(function() {
  function numpf(n, f, s) {
    var n10 = n % 10;
    if ( (n10 == 1) && ( (n == 1) || (n > 20) ) ) {
      return f;
    } else {
      return s;
    }
  }
 
  jQuery.timeago.settings.strings = {
    prefixAgo: null,
    prefixFromNow: null,
    suffixAgo: "síðan",
    suffixFromNow: null,
    seconds: "um mínúta",
    minute: "um mínúta",
    minutes: function(value) { return numpf(value, "%d mínúta", "%d mínútur"); },
    hour: "um klukkustund",
    hours: function(value) { return numpf(value, "%d tími", "%d tímar"); },
    day: "um dagur",
    days: function(value) { return numpf(value, "%d dagur", "%d dagar"); },
    month: "um mánuður",
    months: function(value) { return numpf(value, "%d mánuður", "%d mánuðum"); },
    year: "um ár",
    years: "%d ár"
  };
})();