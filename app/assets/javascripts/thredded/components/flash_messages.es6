(($) => {
  const COMPONENT_SELECTOR = '[data-thredded-flash-message]';

  const destroy = () => {
    $(COMPONENT_SELECTOR).remove();
  };

  document.addEventListener('turbolinks:before-cache', () => {
    destroy()
  });
})(jQuery);
