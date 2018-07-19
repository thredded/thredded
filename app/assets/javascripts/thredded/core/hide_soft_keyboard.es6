//= require thredded/core/thredded

window.Thredded.hideSoftKeyboard = () => {
  const activeElement = document.activeElement;
  if (!activeElement || !activeElement.blur) return;
  activeElement.blur();
};
