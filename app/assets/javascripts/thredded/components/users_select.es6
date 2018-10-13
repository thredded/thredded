//= require thredded/core/on_page_load
//= require thredded/components/user_textcomplete
//= require thredded/dependencies/autosize

(() => {
  const Thredded = window.Thredded;
  const autosize = window.autosize;

  const COMPONENT_SELECTOR = '[data-thredded-users-select]';

  Thredded.UsersSelect = {
    DROPDOWN_MAX_COUNT: 6,
  };

  function parseNames(text) {
    const result = [];
    let current = [];
    let currentIndex = 0;
    let inQuoted = false;
    let inName = false;
    for (let i = 0; i < text.length; ++i) {
      const char = text.charAt(i);
      switch (char) {
        case '"':
          inQuoted = !inQuoted;
          break;
        case ' ':
          if (inName) current.push(char);
          break;
        case ',':
          if (inQuoted) {
            current.push(char);
          } else {
            inName = false;
            if (current.length) {
              result.push({name: current.join(''), index: currentIndex});
              current.length = 0;
            }
          }
          break;
        default:
          if (!inName) currentIndex = i;
          inName = true;
          current.push(char);
      }
    }
    if (current.length) result.current = {name: current.join(''), index: currentIndex};
    return result;
  }

  const initUsersSelect = (textarea) => {
    autosize(textarea);
    // Prevent multiple lines
    textarea.addEventListener('keypress', (evt) => {
      if (evt.keyCode === 13 || evt.keyCode === 10) {
        evt.preventDefault()
      }
    });
    const editor = new Textcomplete.editors.Textarea(textarea);
    const textcomplete = new Textcomplete(editor, {
      dropdown: {
        className: Thredded.UserTextcomplete.DROPDOWN_CLASS_NAME,
        maxCount: Thredded.UsersSelect.DROPDOWN_MAX_COUNT,
      },
    });
    textarea.addEventListener('blur', (evt) => {
      textcomplete.hide();
    });

    const searchFn = Thredded.UserTextcomplete.searchFn({
      url: textarea.getAttribute('data-autocomplete-url'),
      autocompleteMinLength: parseInt(textarea.getAttribute('data-autocomplete-min-length'), 10)
    });
    textcomplete.on('rendered', function() {
      if (textcomplete.dropdown.items.length) {
        textcomplete.dropdown.items[0].activate();
      }
    });
    textcomplete.register([{
      index: 0,
      match: (text) => {
        const names = parseNames(text);
        if (names.current) {
          const {name, index} = names.current;
          const matchData = [name];
          matchData.index = index;
          return matchData;
        } else {
          return null;
        }
      },
      search (term, callback, match) {
        searchFn(term, function(results) {
          const names = parseNames(textarea.value).map(({name}) => name);
          callback(results.filter((result) => names.indexOf(result.name) === -1));
        }, match);
      },
      template: Thredded.UserTextcomplete.formatUser,
      replace  ({name}) {
        if (/,/.test(name)) {
          return `"${name}", `
        } else {
          return `${name}, `
        }
      }
    }]);
  };

  function destroyUsersSelect(textarea) {
    autosize.destroy(textarea);
  }

  window.Thredded.onPageLoad(() => {
    Array.prototype.forEach.call(document.querySelectorAll(COMPONENT_SELECTOR), (node) => {
      initUsersSelect(node);
    });
  });

  document.addEventListener('turbolinks:before-cache', () => {
    Array.prototype.forEach.call(document.querySelectorAll(COMPONENT_SELECTOR), (node) => {
      destroyUsersSelect(node);
    });
  });

})();
