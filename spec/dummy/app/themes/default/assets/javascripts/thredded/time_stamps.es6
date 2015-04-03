class ThreddedTimeStamps {
  constructor() {
    jQuery.timeago.settings.allowFuture = true;
    this.selector = 'abbr.timeago';
  }

  init() {
    jQuery(this.selector).timeago();
  }
}

