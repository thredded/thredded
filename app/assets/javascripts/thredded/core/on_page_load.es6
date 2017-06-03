//= require thredded/core/thredded

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
    // In Turbolinks 5.0.1, turbolinks:load may have already fired (before DOMContentLoaded).
    // If so, add our own DOMContentLoaded listener:
    // See: https://github.com/turbolinks/turbolinks/commit/69d353ea73d10ee6b25c2866fc5706879ba403e3
    if (window.Turbolinks.controller.lastRenderedLocation) {
      document.addEventListener('DOMContentLoaded', () => {
        triggerOnPageLoad();
      });
    }
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

