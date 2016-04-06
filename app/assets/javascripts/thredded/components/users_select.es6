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

  let init = $el => {
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

  $(function() {
    var $nodes = $(COMPONENT_SELECTOR);
    if ($nodes.length) {
      $nodes.each(function() {
        init($(this));
      });
    }
  });
})(jQuery);
