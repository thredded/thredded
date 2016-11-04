(($) => {
  window.Thredded.onPageLoad(() => {
    $('.app-nav-theme li button').click(function(evt) {
      let expiresAt = new Date();
      expiresAt.setMonth(expiresAt.getMonth() + 12);
      document.cookie = 'thredded-theme=' + $(this.parentNode).data('theme') +
        ';expires=' + expiresAt + ';path=/';
      document.location.reload();
    });
  });
})(jQuery);
