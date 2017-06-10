//= require autosize
//= require thredded/core/on_page_load
//= require thredded/components/mention_autocompletion
//= require thredded/components/preview_area

(() => {
  const Thredded = window.Thredded;
  const ThreddedMentionAutocompletion = window.ThreddedMentionAutocompletion;
  const ThreddedPreviewArea = window.ThreddedPreviewArea;
  const autosize = window.autosize;

  const COMPONENT_SELECTOR = '[data-thredded-post-form]';
  const CONTENT_TEXTAREA_SELECTOR = 'textarea[name$="[content]"]';

  const initPostForm = (form) => {
    const textarea = form.querySelector(CONTENT_TEXTAREA_SELECTOR);
    autosize(textarea);
    new ThreddedPreviewArea(form, textarea);
    ThreddedMentionAutocompletion.init(form, textarea);
  };

  const destroyPostForm = (form) => {
    autosize.destroy(form.querySelector(CONTENT_TEXTAREA_SELECTOR));
  };

  Thredded.onPageLoad(() => {
    Array.prototype.forEach.call(document.querySelectorAll(COMPONENT_SELECTOR), (node) => {
      initPostForm(node);
    });
  });

  document.addEventListener('turbolinks:before-cache', () => {
    Array.prototype.forEach.call(document.querySelectorAll(COMPONENT_SELECTOR), (node) => {
      destroyPostForm(node);
    });
  });
})();
