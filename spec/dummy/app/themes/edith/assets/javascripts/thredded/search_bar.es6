class ThreddedSearchBar {
  constructor() {
    this.toggleSelector = '.main-nav-search';
    this.searchBarSelector = '#search';
  }

  init() {
    jQuery(this.toggleSelector).on('click', e => {
      e.preventDefault()

      jQuery(this.searchBarSelector).toggleClass('is-hidden is-visible')
    })
  }
}

