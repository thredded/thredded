// Submit GET forms with turbolinks
(function($) {
  if (window.Turbolinks && window.Turbolinks.supported) {
    window.Thredded.onPageLoad(() => {
      $('[data-thredded-turboform]').on('submit', function(evt) {
        Turbolinks.visit(this.action + (this.action.indexOf('?') === -1 ? '?' : '&') + $(this).serialize());
        evt.preventDefault();
      });
    });
  }
})(jQuery);
