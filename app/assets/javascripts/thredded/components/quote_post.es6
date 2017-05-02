(function() {
  window.Thredded.onPageLoad(() => {
    Array.prototype.forEach.call(document.querySelectorAll('[data-thredded-quote-post]'), (el) => {
      el.addEventListener('click', onClick);
    });
  });

  function onClick(evt) {
    // Handle only left clicks with no modifier keys
    if (evt.button !== 0 || evt.ctrlKey || evt.altKey || evt.metaKey || evt.shiftKey) return;
    evt.preventDefault();
    const target = document.getElementById('post_content');
    target.scrollIntoView();
    target.value = '...';
    fetchReply(evt.target.getAttribute('data-thredded-quote-post'), (replyText) => {
      if (!target.ownerDocument.body.contains(target)) return;
      target.focus();
      target.value = replyText;

      const autosizeUpdateEvent = document.createEvent('Event');
      autosizeUpdateEvent.initEvent('autosize:update', true, false);
      target.dispatchEvent(autosizeUpdateEvent);
      // Scroll into view again as the size might have changed.
      target.scrollIntoView();
    }, (errorMessage) => {
      target.value = errorMessage;
    });
  }

  function fetchReply(url, onSuccess, onError) {
    const request = new XMLHttpRequest();
    request.open('GET', url, /* async */ true);
    request.onload = () => {
      if (request.status >= 200 && request.status < 400) {
        onSuccess(request.responseText);
      } else {
        onError(`Error (${request.status}): ${request.statusText} ${request.responseText}`);
      }
    };
    request.onerror = () => {
      onError('Network Error');
    };
    request.send();
  }
})();
