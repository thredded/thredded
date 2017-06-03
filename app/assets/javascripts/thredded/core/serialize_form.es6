//= require thredded/core/thredded

window.Thredded.serializeForm = (form) => {
  // Can't use new FormData(form).entries() because it's not supported on any IE
  // The below is not a full replacement, but enough for Thredded's purposes.
  return Array.prototype.map.call(form.querySelectorAll('[name]'), (e) => {
    return `${encodeURIComponent(e.name)}=${encodeURIComponent(e.value)}`;
  }).join('&');
};
