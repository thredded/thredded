window.Thredded.onPageLoad(() => {
  Array.prototype.forEach.call(document.querySelectorAll('.app-nav-locale--options--option'), (el) => {
    el.addEventListener('click', (evt) => {
      let expiresAt = new Date();
      expiresAt.setMonth(expiresAt.getMonth() + 12);
      document.cookie = 'locale=' + evt.currentTarget.parentNode.getAttribute('data-locale') +
        ';expires=' + expiresAt + ';path=/';
      Turbolinks.clearCache();
      Turbolinks.visit(document.location);
    });
  });
});
