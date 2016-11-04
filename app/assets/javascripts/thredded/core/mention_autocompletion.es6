class ThreddedMentionAutocompletion {
  constructor($) {
    this.$ = $;
    this.textareaSelector = 'textarea';
  }
  init($nodes){
    const $textarea = $nodes.find(this.textareaSelector);
    this.autocompleteMinLength = parseInt($nodes.data('autocompleteMinLength'), 10);
    this.automentionCompletion($textarea, $nodes.data('autocompleteUrl'));
  }

  escapeHtml(text) {
    return this.$('<div/>').text(text).html();
  }

  formatUser({avatar_url, name, escapeHtml}) {
    return "<div class='thredded--select2-user-result'>" +
      `<img class='thredded--select2-user-result__avatar' src='${this.escapeHtml(avatar_url)}' >` +
      `<span class='thredded--select2-user-result__name'>${this.escapeHtml(name)}</span>` +
      '</div>';
  }


  automentionCompletion($textarea, autocompleteUrl) {
    let mentionAC = this;
    $textarea.textcomplete([{
      match: /(^@|\s@)"?((?:\w| ){1,})$/,
      search (term, callback, match) {
        if(term.length < this.autocompleteMinLength){
          return callback({});
        }
        let termsUrl = `${autocompleteUrl}?q=${term}`;
        $.ajax({url: termsUrl}).done(function (response) {
          callback($.map(response.results, function ({avatar_url, id, name}) {
            return {avatar_url, id, name, match};
          }));
        });
      },
      template ({avatar_url, name}) {
        return mentionAC.formatUser({avatar_url, name});
      },
      replace  ({name, match}) {
        let prefix = match[1];
        if (name.indexOf(" ") > -1) {
          return `${prefix}"${name}" `
        } else {
          return `${prefix}${name} `
        }
      }
    }], {dropdownClassName: 'thredded--textcomplete-dropdown'});
  }
}

