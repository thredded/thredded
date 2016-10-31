(function () {
  const pageLoadCallbacks = [];
  const triggerOnPageLoad = () => {
    console.log('on page load');
    pageLoadCallbacks.forEach((callback) => {
      callback();
    });
  };

  window.Thredded = window.Thredded || {};
  window.Thredded.onPageLoad = (callback) => {
    pageLoadCallbacks.push(callback);
  };

  if ($.fn.turbo) {
    // jQuery Turbolinks.
    $(() => triggerOnPageLoad());
    return;
  }

  $(() => {
    if (!('Turbolinks' in window || !window.Turbolinks.supported)) {
      triggerOnPageLoad();
      return;
    }
    if ('clearCache' in window.Turbolinks) {
      // Turbolinks 5
      document.addEventListener('turbolinks:load', () => {
        triggerOnPageLoad();
      });
    } else {
      // Turbolinks Classic with no jQuery.Turbolinks.
      triggerOnPageLoad();
      document.addEventListener('page:load', () => {
        triggerOnPageLoad();
      })
    }
  });
})(jQuery);

