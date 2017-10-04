(() => {
  const COMPONENT_SELECTOR = '#thredded--container [data-time-ago]';
  const Thredded = window.Thredded;
  if ('timeago' in window) {
    const timeago = window.timeago;
    Thredded.onPageLoad(() => {
      const threddedContainer = document.querySelector('#thredded--container');
      if (!threddedContainer) return;
      timeago().render(
        document.querySelectorAll(COMPONENT_SELECTOR),
        threddedContainer.getAttribute('data-thredded-locale').replace('-', '_'));
    });
    document.addEventListener('turbolinks:before-cache', () => {
      timeago.cancel();
    });
  } else if ('jQuery' in window && 'timeago' in jQuery.fn) {
    const $ = window.jQuery;
    Thredded.onPageLoad(() => {
      const allowFutureWas = $.timeago.settings.allowFuture;
      $.timeago.settings.allowFuture = true;
      $(COMPONENT_SELECTOR).timeago();
      $.timeago.settings.allowFuture = allowFutureWas;
    });
  }
})();
