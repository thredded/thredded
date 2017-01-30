//= require ./preview_area

(function($) {
  const PREVIEW_AREA_SELECTOR = '[data-thredded-preview-area]';
  const PREVIEW_AREA_POST_SELECTOR = '[data-thredded-preview-area-post]';

  class ThreddedPreviewArea {

    constructor($form) {
      const $preview = $form.find(PREVIEW_AREA_SELECTOR);
      if (!$preview.length) return;
      this.$form = $form;
      const $textarea = $form.find('textarea');
      this.textarea = $textarea.get(0);
      this.preview = $preview.get(0);
      this.previewPost = $form.find(PREVIEW_AREA_POST_SELECTOR).get(0);
      this.previewUrl = this.preview.getAttribute('data-thredded-preview-url');

      const onChange = Thredded.debounce(() => {
        this.updatePreview()
      }, 200, false);

      this.textarea.addEventListener('input', onChange, false);
      // Listen to the jQuery change event as that's what is triggered by plugins such as jQuery.textcomplete.
      $textarea.on('change', onChange);

      this.requestId = 0;
    }

    updatePreview() {
      this.requestId++;
      const requestId = this.requestId;
      $.ajax({
        type: this.$form.attr('method'),
        url: this.previewUrl,
        data: this.$form.serialize(),
      }).done((data) => {
        if (requestId == this.requestId) {
          // Ignore older responses received out-of-order
          this.onPreviewResponse(data);
        }
      });
    }

    onPreviewResponse(data) {
      this.preview.style.display = 'block';
      this.previewPost.innerHTML = data;
    }
  }

  window.ThreddedPreviewArea = ThreddedPreviewArea;
})(jQuery);
