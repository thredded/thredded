//= require thredded/core/thredded
//= require thredded/core/debounce
//= require thredded/core/serialize_form
//= require thredded/components/spoilers

(() => {
  const Thredded = window.Thredded;
  const PREVIEW_AREA_SELECTOR = '[data-thredded-preview-area]';
  const PREVIEW_AREA_POST_SELECTOR = '[data-thredded-preview-area-post]';

  class ThreddedPreviewArea {

    constructor(form, textarea) {
      const preview = form.querySelector(PREVIEW_AREA_SELECTOR);
      if (!preview || !textarea) return;
      this.form = form;
      this.preview = preview;
      this.previewPost = form.querySelector(PREVIEW_AREA_POST_SELECTOR);
      this.previewUrl = this.preview.getAttribute('data-thredded-preview-url');

      let prevValue = null;
      const onChange = Thredded.debounce(() => {
        if (prevValue !== textarea.value) {
          this.updatePreview();
          prevValue = textarea.value;
        }
      }, 200, false);

      textarea.addEventListener('input', onChange, false);
      if(textarea.value.trim() !== '') {
        onChange();
      }
      this.requestId = 0;
    }

    updatePreview() {
      this.requestId++;
      const requestId = this.requestId;
      const request = new XMLHttpRequest();
      request.open(this.form.method, this.previewUrl, /* async */ true);
      request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
      request.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
      request.onload = () => {
        if (
          // Ignore server errors
          request.status >= 200 && request.status < 400 &&
          // Ignore older responses received out-of-order
          requestId === this.requestId) {
          this.onPreviewResponse(request.responseText);
        }
      };
      request.send(Thredded.serializeForm(this.form));
    }

    onPreviewResponse(data) {
      this.preview.style.display = 'block';
      this.previewPost.innerHTML = data;
      Thredded.spoilers.init(this.previewPost);
    }
  }

  window.ThreddedPreviewArea = ThreddedPreviewArea;
})();
