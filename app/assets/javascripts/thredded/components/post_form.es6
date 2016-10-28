(($) => {
  const COMPONENT_SELECTOR = '[data-thredded-post-form]';

  class ThreddedPostForm {
    constructor() {
      this.textareaSelector = 'textarea';
    }

    init($nodes) {
      let $textarea = $nodes.find(this.textareaSelector);
      this.autosize($textarea);
      this.automentionCompletion($textarea, $nodes.data('autocompleteUrl'));
    }

    autosize($textarea) {
      $textarea.autosize()
    }

    escapeHtml(text) {
      return $('<div/>').text(text).html();
    }

    formatUser({avatar_url, name, escapeHtml}) {
      return "<div class='thredded--select2-user-result'>" +
        `<img class='thredded--select2-user-result__avatar' src='${escapeHtml(avatar_url)}' >` +
        `<span class='thredded--select2-user-result__name'>${escapeHtml(name)}</span>` +
        '</div>';
    }

    automentionCompletion($textarea, autocompleteUrl) {
      let formatUser = this.formatUser;
      let escapeHtml = this.escapeHtml;

      $textarea.textcomplete([{
        match: /(^@|\s@)"?((?:\w| ){1,})$/,
        search: function (term, callback, match) {
          let termsUrl = `${autocompleteUrl}?q=${term}`;
          $.ajax({url: termsUrl}).done(function (response) {
            callback($.map(response.results, function ({avatar_url, id, name}) {
              return {avatar_url, id, name, match};
            }));
          });
        },
        template: function ({avatar_url, name}) {
          return formatUser({avatar_url, name, escapeHtml})
        },
        replace: function ({name, match}) {
          let prefix = match[1];
          if (name.indexOf(" ") > -1) {
            return `${prefix}"${name}" `
          } else {
            return `${prefix}${name} `
          }
        }
      }]);
    }

    destroy($nodes) {
      $nodes.find(this.textareaSelector).trigger('autosize.destroy');
    }
  }

  window.Thredded.onPageLoad(() => {
    const $nodes = $(COMPONENT_SELECTOR);
    if ($nodes.length) {
      new ThreddedPostForm().init($nodes);
    }
  });

  document.addEventListener('turbolinks:before-cache', () => {
    const $nodes = $(COMPONENT_SELECTOR);
    if ($nodes.length) {
      new ThreddedPostForm().destroy($nodes);
    }
  });
})(jQuery);
