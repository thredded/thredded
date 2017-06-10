class ThreddedMentionAutocompletion {
  constructor() {
    this.textareaSelector = 'textarea';
  }

  init(node) {
    this.autocompleteMinLength = parseInt(node.getAttribute('data-autocomplete-min-length'), 10);
    this.automentionCompletion(node.querySelector(this.textareaSelector), node.getAttribute('data-autocomplete-url'));
  }

  escapeHtml(text) {
    const node = document.createElement('div');
    node.textContent = text;
    return node.innerHTML;
  }

  formatUser({avatar_url, name, escapeHtml}) {
    return "<div class='thredded--select2-user-result'>" +
      `<img class='thredded--select2-user-result__avatar' src='${this.escapeHtml(avatar_url)}' >` +
      `<span class='thredded--select2-user-result__name'>${this.escapeHtml(name)}</span>` +
      '</div>';
  }

  automentionCompletion(textarea, autocompleteUrl) {
    const editor = new Textcomplete.editors.Textarea(textarea);
    const textcomplete = new Textcomplete(editor, {
      dropdown: ThreddedMentionAutocompletion.DROPDOWN_OPTIONS,
    });
    textcomplete.register([{
      match: ThreddedMentionAutocompletion.MATCH_RE,
      search (term, callback, match) {
        if(term.length < this.autocompleteMinLength){
          callback([]);
          return;
        }
        const request = new XMLHttpRequest();
        request.open('GET', `${autocompleteUrl}?q=${term}`, /* async */ true);
        request.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
        request.onload = () => {
          // Ignore errors
          if (request.status < 200 || request.status >= 400) {
            callback([]);
            return;
          }
          callback(JSON.parse(request.responseText).results.map(({avatar_url, id, name}) => {
            return {avatar_url, id, name, match};
          }));
        };
        request.send();
      },
      template: ({avatar_url, name}) => {
        return this.formatUser({avatar_url, name});
      },
      replace  ({name, match}) {
        let prefix = match[1];
        if (/[., ()]/.test(name)) {
          return `${prefix}"${name}" `
        } else {
          return `${prefix}${name} `
        }
      }
    }]);
  }
}

ThreddedMentionAutocompletion.MATCH_RE = /(^@|\s@)"?([\w.,\- ()]+)$/;
ThreddedMentionAutocompletion.DROPDOWN_OPTIONS = {
  className: 'thredded--textcomplete-dropdown',
  maxCount: 6,
};
