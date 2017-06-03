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

  const initPostForm = (form) => {
    const textarea = form.querySelector('textarea');
    autosize(textarea);
    new ThreddedPreviewArea(form);
    new ThreddedMentionAutocompletion().init(form);
  };

  const destroyPostForm = (form) => {
    autosize.destroy(form.querySelector('textarea'));
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
