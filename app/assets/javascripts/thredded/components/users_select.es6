//= require thredded/core/on_page_load

(() => {
  const COMPONENT_SELECTOR = '[data-thredded-users-select]';

  const formatUser = (user, container, query, escapeHtml) => {
    if (user.loading) return user.text;
    return "<div class='thredded--select2-user-result'>" +
      `<img class='thredded--select2-user-result__avatar' src='${escapeHtml(user.avatar_url)}' >` +
      `<span class='thredded--select2-user-result__name'>${escapeHtml(user.name)}</span>` +
      '</div>';
  };

  const formatUserSelection = (user, container, escapeHtml) => {
    return `<span class='thredded--select2-user-selection'>` +
      `<img class='thredded--select2-user-selection__avatar' src='${escapeHtml(user.avatar_url)}' >` +
      `<span class='thredded--select2-user-selection__name'>${escapeHtml(user.name)}</span>` +
      '</span>';
  };

  const initSelection = ($input, callback) => {
    const input = $input.get(0);
    const ids = (input.value || '').split(',');
    if (ids.length && ids[0] !== '') {
      const request = new XMLHttpRequest();
      request.open('GET', `${input.getAttribute('data-autocomplete-url')}?ids=${ids.join(',')}`, /* async */ true);
      request.onload = () => {
        // Ignore errors
        if (request.status < 200 || request.status >= 400) {
          callback([]);
          return;
        }
        callback(JSON.parse(request.responseText).results);
      };
      request.send();
    } else {
      callback([]);
    }
  };

  const initUsersSelect = (input) => {
    jQuery(input).select2({
      ajax: {
        cache: true,
        data: query => ({q: query}),
        results: data => data,
        dataType: 'json',
        url: input.getAttribute('data-autocomplete-url')
      },
      containerCssClass: 'thredded--select2-container',
      dropdownCssClass: 'thredded--select2-drop',
      initSelection: initSelection,
      minimumInputLength: input.getAttribute('data-autocomplete-min-length'),
      multiple: true,
      formatResult: formatUser,
      formatSelection: formatUserSelection
    });
  };

  const destroyUsersSelect = (input) => {
    jQuery(input).select2('destroy');
  };

  window.Thredded.onPageLoad(() => {
    Array.prototype.forEach.call(document.querySelectorAll(COMPONENT_SELECTOR), (node) => {
      initUsersSelect(node);
    });
  });

  document.addEventListener('turbolinks:before-cache', () => {
    // Turbolinks 5 clones the body node for caching, losing all the bound
    // events. Undo the select2 transformation before storing to cache,
    // so that it applies cleanly on restore.
    Array.prototype.forEach.call(document.querySelectorAll(COMPONENT_SELECTOR), (node) => {
      destroyUsersSelect(node);
    });

    Array.prototype.forEach.call(document.querySelectorAll('.select2-drop, .select2-drop-mask'), (node) => {
      node.parentNode.removeChild(node);
    });
  });

})(jQuery);
