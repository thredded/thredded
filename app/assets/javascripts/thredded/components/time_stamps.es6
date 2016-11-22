(($) => {
  const COMPONENT_SELECTOR = '#thredded--container [data-time-ago]';

  window.Thredded.onPageLoad(() => {
    const allowFutureWas = jQuery.timeago.settings.allowFuture;
    $.timeago.settings.allowFuture = true;
    //$(COMPONENT_SELECTOR).timeago();
    $.timeago.settings.allowFuture = allowFutureWas;
  });
})(jQuery);
