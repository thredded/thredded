// Turbolinks nonce CSP support.
// See https://github.com/turbolinks/turbolinks/issues/430
document.addEventListener('turbolinks:request-start', function(event) {
  var nonceTag = document.querySelector("meta[name='csp-nonce']");
  if (nonceTag) event.data.xhr.setRequestHeader('X-Turbolinks-Nonce', nonceTag.content);
});
document.addEventListener('turbolinks:before-cache', function() {
  Array.prototype.forEach.call(document.querySelectorAll('script[nonce]'), function(element) {
    if (element.nonce) element.setAttribute('nonce', element.nonce);
  });
});
