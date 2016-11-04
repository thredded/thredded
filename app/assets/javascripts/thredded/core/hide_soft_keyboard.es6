window.Thredded = window.Thredded || {};
window.Thredded.hideSoftKeyboard = () => {
  const activeElement = document.activeElement;
  if (!activeElement || !activeElement.blur) return;
  activeElement.blur();
};
