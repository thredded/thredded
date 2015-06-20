//= require jquery
//= require jquery_ujs
//= require_tree ./thredded/vendor
//= require_tree ./thredded

class Thredded {
  constructor() {
    this.topicForm = new ThreddedTopicForm();
    this.privateTopicForm = new ThreddedPrivateTopicForm();
    this.postForm = new ThreddedPostForm();
    this.kbShortcuts = new ThreddedKeyboardShortcuts();
    this.timestamps = new ThreddedTimeStamps();
    this.searchBar = new ThreddedSearchBar();
    this.currentlyOnline = new ThreddedCurrentlyOnline();
  }
}

Thredded.new = function(){ return new Thredded; }
