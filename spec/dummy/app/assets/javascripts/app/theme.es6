(($) => {
  window.Thredded.onPageLoad(() => {
    $('.app-nav-theme li').click((evt) => {
      if (/\bapp-current\b/.test(evt.target.className)) return;
      let expiresAt = new Date();
      expiresAt.setMonth(expiresAt.getMonth() + 12);
      document.cookie = 'thredded-theme=' + $(evt.target).data('theme') +
        ';expires=' + expiresAt + ';path=/';
      Turbolinks.clearCache();
      Turbolinks.visit(document.location);
    });
  });
})(jQuery);
