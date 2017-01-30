//= require ./thredded

/**
 * Return a function, that, as long as it continues to be invoked, will
 * not be triggered. The function will be called after it stops being
 * called for `wait` milliseconds. If `immediate` is passed, trigger the
 * function on the leading edge, instead of the trailing.
 * Based on https://john-dugan.com/javascript-debounce/.
 *
 * @param {Function} func
 * @param {Number} wait in milliseconds
 * @param {Boolean} immediate
 * @returns {Function}
 */
window.Thredded.debounce = function(func, wait, immediate) {
  let timeoutId = null;
  return function() {
    const context = this, args = arguments;
    const later = function() {
      timeoutId = null;
      if (!immediate) {
        func.apply(context, args);
      }
    };
    const callNow = immediate && !timeoutId;
    clearTimeout(timeoutId);
    timeoutId = setTimeout(later, wait || 200);
    if (callNow) {
      func.apply(context, args);
    }
  };
};
