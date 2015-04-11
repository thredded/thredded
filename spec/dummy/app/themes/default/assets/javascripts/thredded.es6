class Thredded {
  constructor() {
    this.topicForm = new ThreddedTopicForm();
    this.privateTopicForm = new ThreddedPrivateTopicForm();
    this.postForm = new ThreddedPostForm();
    this.kbShortcuts = new ThreddedKeyboardShortcuts();
    this.timestamps = new ThreddedTimeStamps();
    this.searchBar = new ThreddedSearchBar();
    this.dropForms = new ThreddedDropForms();
  }
}

Thredded.new = function(){ return new Thredded; }
