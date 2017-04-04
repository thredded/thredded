(($) => {
  window.Thredded.onPageLoad(() => {
    $('.app-nav-locale--options--option').click(function(evt) {
      let expiresAt = new Date();
      expiresAt.setMonth(expiresAt.getMonth() + 12);
      document.cookie = 'locale=' + $(this.parentNode).data('locale') +
        ';expires=' + expiresAt + ';path=/';
      Turbolinks.clearCache();
      Turbolinks.visit(document.location);
    });
  });
})(jQuery);
