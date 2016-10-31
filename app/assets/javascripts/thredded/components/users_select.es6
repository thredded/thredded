($ => {
  const COMPONENT_SELECTOR = '[data-thredded-users-select]';


  let formatUser = (user, container, query, escapeHtml) => {
    if (user.loading) return user.text;
    return "<div class='thredded--select2-user-result'>" +
      `<img class='thredded--select2-user-result__avatar' src='${escapeHtml(user.avatar_url)}' >` +
      `<span class='thredded--select2-user-result__name'>${escapeHtml(user.name)}</span>` +
      '</div>';
  };

  let formatUserSelection = (user, container, escapeHtml) => {
    return `<span class='thredded--select2-user-selection'>` +
      `<img class='thredded--select2-user-selection__avatar' src='${escapeHtml(user.avatar_url)}' >` +
      `<span class='thredded--select2-user-selection__name'>${escapeHtml(user.name)}</span>` +
      '</span>';
  };

  let initSelection = ($el, callback) => {
    let ids = ($el.val() || '').split(',');
    if (ids.length && ids[0] != '') {
      $.ajax(`${$el.data('autocompleteUrl')}?ids=${ids.join(',')}`, {dataType: 'json'}).done(data => callback(data.results));
    } else {
      callback([]);
    }
  };

  let initOne = $el => {
    $el.select2({
      ajax: {
        cache: true,
        data: query => ({q: query}),
        results: data => data,
        dataType: 'json',
        url: $el.data('autocompleteUrl')
      },
      containerCssClass: 'thredded--select2-container',
      dropdownCssClass: 'thredded--select2-drop',
      initSelection: initSelection,
      minimumInputLength: 2,
      multiple: true,
      formatResult: formatUser,
      formatSelection: formatUserSelection
    });
  };

  let init = () => {
    $(COMPONENT_SELECTOR).each(function() {
      initOne($(this));
    });
  };

  let destroy = () => {
    $(COMPONENT_SELECTOR).each(function() {
      $(this).select2('destroy');
    });
    $('.select2-drop, .select2-drop-mask').remove();
  };

  window.Thredded.onPageLoad(() => {
    init()
  });

  document.addEventListener('turbolinks:before-cache', () => {
    // Turbolinks 5 clones the body node for caching, losing all the bound
    // events. Undo the select2 transformation before storing to cache,
    // so that it applies cleanly on restore.
    destroy()
  });

})(jQuery);
