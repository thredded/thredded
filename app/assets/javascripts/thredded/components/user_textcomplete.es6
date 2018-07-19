//= require thredded/core/thredded
//= require thredded/core/escape_html

(() => {
  const Thredded = window.Thredded;

  Thredded.UserTextcomplete = {
    DROPDOWN_CLASS_NAME: 'thredded--textcomplete-dropdown',

    formatUser({avatar_url, name, display_name}) {
      return "<div class='thredded--textcomplete-user-result'>" +
        `<img class='thredded--textcomplete-user-result__avatar' src='${Thredded.escapeHtml(avatar_url)}' >` +
        `<span class='thredded--textcomplete-user-result__name'>${Thredded.escapeHtml(name)}</span>` +
        (name !== display_name && display_name ?
          `<span class='thredded--textcomplete-user-result__display_name'>${Thredded.escapeHtml(display_name)}</span>` :
          '') +
        '</div>';
    },

    searchFn({url, autocompleteMinLength}) {
      return function search(term, callback, match) {
        if (term.length < autocompleteMinLength) {
          callback([]);
          return;
        }
        const request = new XMLHttpRequest();
        request.open('GET', `${url}?q=${term}`, /* async */ true);
        request.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
        request.onload = () => {
          // Ignore errors
          if (request.status < 200 || request.status >= 400) {
            callback([]);
            return;
          }
          callback(JSON.parse(request.responseText).results.map(({avatar_url, id, display_name, name}) => {
            return {avatar_url, id, name, display_name, match};
          }));
        };
        request.send();
      }
    }
  };

  document.addEventListener('turbolinks:before-cache', () => {
    Array.prototype.forEach.call(
      document.getElementsByClassName(Thredded.UserTextcomplete.DROPDOWN_CLASS_NAME), (node) => {
        node.parentNode.removeChild(node);
      });
  });
})();
