(($) => {
  const isTurbolinks = 'Turbolinks' in window && window.Turbolinks.supported;
  const isTurbolinks5 = isTurbolinks && 'clearCache' in window.Turbolinks;
  const isjQueryTurbolinks = 'turbo' in $.fn;

  let onPageLoadFiredOnce = false;
  const pageLoadCallbacks = [];
  const triggerOnPageLoad = () => {
    pageLoadCallbacks.forEach((callback) => {
      callback();
    });
    onPageLoadFiredOnce = true;
  };

  window.Thredded = window.Thredded || {};

  // Fires the callback on DOMContentLoaded or a Turbolinks page load.
  // If called from an async script on the first page load, and the DOMContentLoad event
  // has already fired, will execute the callback immediately.
  window.Thredded.onPageLoad = (callback) => {
    pageLoadCallbacks.push(callback);
    // With async script loading, a callback may be added
    // after the DOMContentLoaded event has already triggered.
    // This means we will not receive turbolinks:load on Turbolinks 5.
    if (isTurbolinks5 && !onPageLoadFiredOnce && window.Thredded.DOMContentLoadedFired) {
      callback();
    }
  };

  if (!isTurbolinks || isjQueryTurbolinks) {
    $(() => triggerOnPageLoad());
    return;
  }

  if (isTurbolinks5) {
    document.addEventListener('turbolinks:load', () => {
      triggerOnPageLoad();
    });
  } else {
    // Turbolinks Classic with no jQuery.Turbolinks:
    $(() => {
      triggerOnPageLoad();
      document.addEventListener('page:load', () => {
        triggerOnPageLoad();
      })
    });
  }
})(jQuery);

