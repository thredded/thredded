class ThreddedSearchBar {
  constructor() {
    this.toggleSelector = '.main-nav-search a';
    this.searchBarSelector = '#search-bar';
  }

  init() {
    var _self = this;

    jQuery(this.toggleSelector).on('click', e => {
      e.preventDefault();

      jQuery(_self.searchBarSelector).toggleClass('is-hidden is-visible');
    })
  }
}

