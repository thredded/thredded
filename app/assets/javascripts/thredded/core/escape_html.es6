//= require thredded/core/thredded

window.Thredded.escapeHtml = function(text) {
  const node = document.createElement('div');
  node.textContent = text;
  return node.innerHTML;
};
