//= require thredded/components/user_textcomplete

const ThreddedMentionAutocompletion = {
  MATCH_RE: /(^@|\s@)"?([\w.,\- ()]+)$/,
  DROPDOWN_MAX_COUNT: 6,

  init(form, textarea) {
    const editor = new Textcomplete.editors.Textarea(textarea);
    const textcomplete = new Textcomplete(editor, {
      dropdown: {
        className: Thredded.UserTextcomplete.DROPDOWN_CLASS_NAME,
        maxCount: ThreddedMentionAutocompletion.DROPDOWN_MAX_COUNT
      },
    });
    textcomplete.on('rendered', function() {
      if (textcomplete.dropdown.items.length) {
        textcomplete.dropdown.items[0].activate();
      }
    });
    textcomplete.register([{
      match: ThreddedMentionAutocompletion.MATCH_RE,
      search: Thredded.UserTextcomplete.searchFn({
        url: form.getAttribute('data-autocomplete-url'),
        autocompleteMinLength: parseInt(form.getAttribute('data-autocomplete-min-length'), 10)
      }),
      template: Thredded.UserTextcomplete.formatUser,
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
};

window.ThreddedMentionAutocompletion = ThreddedMentionAutocompletion;
