class Thredded {
  constructor() {
    this.topicForm = new ThreddedTopicForm();
    this.postForm = new ThreddedPostForm();
    this.kbShortcuts = new ThreddedKeyboardShortcuts();
    this.timestamps = new ThreddedTimeStamps();
    this.searchBar = new ThreddedSearchBar();
  }
}

Thredded.new = function(){ return new Thredded; }
