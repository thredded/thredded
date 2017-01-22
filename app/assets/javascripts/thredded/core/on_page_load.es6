//= require ./thredded

(() => {
  const isTurbolinks = 'Turbolinks' in window && window.Turbolinks.supported;
  const isTurbolinks5 = isTurbolinks && 'clearCache' in window.Turbolinks;

  let onPageLoadFiredOnce = false;
  const pageLoadCallbacks = [];
  const triggerOnPageLoad = () => {
    pageLoadCallbacks.forEach((callback) => {
      callback();
    });
    onPageLoadFiredOnce = true;
  };

  // Fires the callback on DOMContentLoaded or a Turbolinks page load.
  // If called from an async script on the first page load, and the DOMContentLoad event
  // has already fired, will execute the callback immediately.
  window.Thredded.onPageLoad = (callback) => {
    pageLoadCallbacks.push(callback);
    // With async script loading, a callback may be added after the DOMContentLoaded event has already triggered.
    // This means we will receive neither a DOMContentLoaded event, nor a turbolinks:load event on Turbolinks 5.
    if (!onPageLoadFiredOnce && window.Thredded.DOMContentLoadedFired) {
      callback();
    }
  };

  if (isTurbolinks5) {
    document.addEventListener('turbolinks:load', () => {
      triggerOnPageLoad();
    });
  } else {
    // Turbolinks Classic (with or without jQuery.Turbolinks), or no Turbolinks:
    if (!window.Thredded.DOMContentLoadedFired) {
      document.addEventListener('DOMContentLoaded', () => {
        triggerOnPageLoad();
      });
    }
    if (isTurbolinks) {
      document.addEventListener('page:load', () => {
        triggerOnPageLoad();
      })
    }
  }
})();

