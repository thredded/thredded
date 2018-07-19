//= require thredded/core/on_page_load

(() => {
  const Thredded = window.Thredded;
  const COMPONENT_SELECTOR = '.thredded--post--content--spoiler';
  const OPEN_CLASS = 'thredded--post--content--spoiler--is-open';

  Thredded.spoilers = {
    init(root) {
      Array.prototype.forEach.call(root.querySelectorAll(COMPONENT_SELECTOR), (node) => {
        node.addEventListener('mousedown', (evt) => {
          evt.stopPropagation();
          this.toggle(evt.currentTarget);
        });
        node.addEventListener('keypress', (evt) => {
          if (event.key === ' ' || event.key === 'Enter') {
            evt.preventDefault();
            evt.stopPropagation();
            this.toggle(evt.currentTarget);
          }
        });
      });
    },

    toggle(node) {
      const isOpen = node.classList.contains(OPEN_CLASS);
      node.classList.toggle(OPEN_CLASS);
      node.setAttribute('aria-expanded', isOpen ? 'false' : 'true');
      node.firstElementChild.setAttribute('aria-hidden', isOpen ? 'false' : 'true');
      node.lastElementChild.setAttribute('aria-hidden', isOpen ? 'true' : 'false');
    }
  };

  Thredded.onPageLoad(() => {
    Thredded.spoilers.init(document);
  });
})();
