//= require thredded/core/on_page_load

window.Thredded.onPageLoad(() => {
  if ('Rails' in window) {
    window.Rails.refreshCSRFTokens();
  } else if ('jQuery' in window && 'rails' in window.jQuery) {
    window.jQuery.rails.refreshCSRFTokens();
  }
});
