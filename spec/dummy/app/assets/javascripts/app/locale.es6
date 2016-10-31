(($) => {
  window.Thredded.onPageLoad(() => {
    $('.app-nav-locale li').click((evt) => {
      let expiresAt = new Date();
      expiresAt.setMonth(expiresAt.getMonth() + 12);
      document.cookie = 'locale=' + $(evt.target).data('locale') +
        ';expires=' +expiresAt + ';path=/';
      document.location.reload();
    });
  });
})(jQuery);
