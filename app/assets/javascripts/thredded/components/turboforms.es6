// Submit GET forms with turbolinks
(function($) {
  if (window.Turbolinks && window.Turbolinks.supported) {
    window.Thredded.onPageLoad(() => {
      $('[data-thredded-turboform]').on('submit', function(evt) {
        evt.preventDefault();
        Turbolinks.visit(this.action + (this.action.indexOf('?') === -1 ? '?' : '&') + $(this).serialize());

        // On mobile the soft keyboard doesn't won't go away after the submit since we're submitting with
        // Turbolinks. Hide it:
        window.Thredded.hideSoftKeyboard();
      });
    });
  }
})(jQuery);
