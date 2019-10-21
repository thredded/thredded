//= require thredded/core/thredded
(function() {
  const Thredded = window.Thredded;
  Thredded.isSubmitHotkey = (evt) => {
    // Ctrl+Enter.
    return evt.ctrlKey && (evt.keyCode === 13 || evt.keyCode === 10 /* http://crbug.com/79407 */);
  };

  document.addEventListener('keypress', (evt) => {
    if (Thredded.isSubmitHotkey(evt)) {
      const submitButton = document.querySelector('[data-thredded-submit-hotkey] [type="submit"]');
      if (!submitButton) return;
      evt.preventDefault();
      // Focus first for better visual feedback.
      submitButton.focus();
      submitButton.click();
    }
  });
})();
