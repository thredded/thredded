//= require autosize
//= require thredded/core/on_page_load
//= require thredded/components/mention_autocompletion
//= require thredded/components/preview_area

(() => {
  const Thredded = window.Thredded;
  const ThreddedMentionAutocompletion = window.ThreddedMentionAutocompletion;
  const ThreddedPreviewArea = window.ThreddedPreviewArea;
  const autosize = window.autosize;

  const COMPONENT_SELECTOR = '[data-thredded-topic-form]';
  const TITLE_SELECTOR = '[name$="topic[title]"]';
  const COMPACT_CLASS = 'thredded--is-compact';
  const EXPANDED_CLASS = 'thredded--is-expanded';
  const ESCAPE_KEY_CODE = 27;

  const initTopicForm = (form) => {
    const textarea = form.querySelector('textarea');
    autosize(textarea);
    new ThreddedPreviewArea(form);
    new ThreddedMentionAutocompletion().init(form);

    if (!form.classList.contains(COMPACT_CLASS)) {
      return;
    }

    const title = form.querySelector(TITLE_SELECTOR);
    title.addEventListener('focus', () => {
      toggleExpanded(form, true);
    });

    [title, textarea].forEach((node) => {
      // Un-expand on Escape key.
      node.addEventListener('keydown', (evt) => {
        if (evt.keyCode === ESCAPE_KEY_CODE) {
          evt.target.blur();
          toggleExpanded(form, false);
        }
      });

      // Un-expand on blur if the new focus element is outside of the same form and
      // all the form inputs are empty.
      node.addEventListener('blur', () => {
        // This listener will be fired right after the blur event has finished.
        const listener = (evt) => {
          if (!form.contains(evt.target) && !title.value && !textarea.value) {
            toggleExpanded(form, false);
          }
          document.body.removeEventListener('touchend', listener);
          document.body.removeEventListener('mouseup', listener);
        };
        document.body.addEventListener('mouseup', listener);
        document.body.addEventListener('touchend', listener);
      })
    });
  };

  const toggleExpanded = (form, expand) => {
    if (expand) {
      form.classList.remove(COMPACT_CLASS);
      form.classList.add(EXPANDED_CLASS);
    } else {
      form.classList.remove(EXPANDED_CLASS);
      form.classList.add(COMPACT_CLASS);
    }
  };

  const destroyTopicForm = (form) => {
    autosize.destroy(form.querySelector('textarea'));
  };

  Thredded.onPageLoad(() => {
    Array.prototype.forEach.call(document.querySelectorAll(COMPONENT_SELECTOR), (node) => {
      initTopicForm(node);
    });
  });

  document.addEventListener('turbolinks:before-cache', () => {
    Array.prototype.forEach.call(document.querySelectorAll(COMPONENT_SELECTOR), (node) => {
      destroyTopicForm(node);
    });
  });
})();


