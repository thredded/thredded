//= require thredded/core/on_page_load
//= require thredded/core/serialize_form

// Submit GET forms with turbolinks
(() => {
  const Thredded = window.Thredded;
  const Turbolinks = window.Turbolinks;

  Thredded.onPageLoad(() => {
    if (!Turbolinks || !Turbolinks.supported) return;
    Array.prototype.forEach.call(document.querySelectorAll('[data-thredded-turboform]'), (form) => {
      form.addEventListener('submit', handleSubmit);
    });
  });

  const handleSubmit = (evt) => {
    evt.preventDefault();
    const form = evt.currentTarget;
    Turbolinks.visit(form.action + (form.action.indexOf('?') === -1 ? '?' : '&') + Thredded.serializeForm(form));

    // On mobile the soft keyboard doesn't won't go away after the submit since we're submitting with
    // Turbolinks. Hide it:
    Thredded.hideSoftKeyboard();
  };
})();
