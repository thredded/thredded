jQuery($ => {
  $('.app-nav-theme li').click((evt) => {
    let expiresAt = new Date();
    expiresAt.setMonth(expiresAt.getMonth() + 12);
    document.cookie = 'thredded-theme=' + $(evt.target).data('theme') + ';expires=' + expiresAt + ';path=/';
    document.location.reload();
  });
});
