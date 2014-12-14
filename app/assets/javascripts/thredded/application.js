jQuery(function ($) {
  var $thredded = $('.thredded-page');
  if (!$thredded.length) return;
  $thredded.find('select[multiple]').select2();
});
