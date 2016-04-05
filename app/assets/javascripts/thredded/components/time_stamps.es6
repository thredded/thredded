jQuery(function($) {
  const COMPONENT_SELECTOR = '#thredded--container abbr.timeago';

  var allowFutureWas = jQuery.timeago.settings.allowFuture;
  $.timeago.settings.allowFuture = true;
  $(COMPONENT_SELECTOR).timeago();
  $.timeago.settings.allowFuture = allowFutureWas;
});
