const Turbolinks = require('turbolinks');

// Monkey patch Turbolinks to render 403, 404 & 500 normally
// See https://github.com/turbolinks/turbolinks/issues/179
Turbolinks.HttpRequest.prototype.requestLoaded = function() {
  return this.endRequest(function() {
    var code = this.xhr.status;
    if (200 <= code && code < 300 ||
      code === 403 || code === 404 || code === 500) {
      this.delegate.requestCompletedWithResponse(
        this.xhr.responseText,
        this.xhr.getResponseHeader("Turbolinks-Location"));
    } else {
      this.failed = true;
      this.delegate.requestFailedWithStatusCode(code, this.xhr.responseText);
    }
  }.bind(this));
};

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
