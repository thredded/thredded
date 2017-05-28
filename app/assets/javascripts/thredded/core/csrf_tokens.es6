//= require thredded/core/on_page_load

window.Thredded.onPageLoad(() => {
  window.Rails.refreshCSRFTokens();
});
