//= require thredded/core/on_page_load

(() => {
  const Thredded = window.Thredded;

  const COMPONENT_SELECTOR = '[data-thredded-currently-online]';
  const EXPANDED_CLASS = 'thredded--is-expanded';

  const handleMouseEnter = (evt) => {
    evt.target.classList.add(EXPANDED_CLASS);
  };

  const handleMouseLeave = (evt) => {
    evt.target.classList.remove(EXPANDED_CLASS);
  };

  const handleTouchStart = (evt) => {
    evt.target.classList.toggle(EXPANDED_CLASS);
  };

  const initCurrentlyOnline = (node) => {
    node.addEventListener('mouseenter', handleMouseEnter);
    node.addEventListener('mouseleave', handleMouseLeave);
    node.addEventListener('touchstart', handleTouchStart);
  };

  Thredded.onPageLoad(() => {
    Array.prototype.forEach.call(document.querySelectorAll(COMPONENT_SELECTOR), (node) => {
      initCurrentlyOnline(node);
    });
  });
})();
