class ThreddedDropForms {
  constructor() {
    this.toggleSelectors = '.main-nav-sign-in a, .main-nav-notification-preferences a';
  }

  init() {
    jQuery(this.toggleSelectors).on('click', function(e) {
      e.preventDefault()
      const target_selector = this.parentNode.className.replace('main-nav-', '.')

      jQuery(target_selector).toggleClass('is-hidden is-visible')
      jQuery('#main-container').toggleClass('is-in-the-background')
    })
  }
}
