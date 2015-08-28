//= require babel/polyfill
//= require jquery
//= require jquery_ujs
//= require_tree ./thredded/vendor
//= require_tree ./thredded

(function() {

  const pageComponents = [
    {pageId: 'thredded-edit-post', components: ['postForm']},
    {pageId: 'thredded-new-private-topic', components: ['postForm', 'privateTopicForm']},
    {pageId: 'thredded-new-topic', components: ['postForm', 'topicForm']},
    {pageId: 'thredded-posts', components: ['postForm']},
    {pageId: 'thredded-private-topics-index', components: ['privateTopicForm']},
    {pageId: 'thredded-theme', components: ['topicForm', 'privateTopicForm', 'postForm', 'searchBar']},
    {pageId: 'thredded-topics-index', components: ['topicForm']}
  ];

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

    init(rootNode) {
      // This method is invoked multiple times on the same instance when using Turbolinks.
      this.currentlyOnline.init();
      this.timestamps.init();
      for (let {pageId, components} of pageComponents) {
        if (rootNode.getAttribute('data-thredded-page-id') === pageId) {
          for (let component of components) {
            this[component].init();
          }
        }
      }
    }
  }

  const globalKey = 'thredded';
  const rootNodeId = 'thredded-container';

  jQuery(function() {
    var rootNode = document.getElementById(rootNodeId);
    if (rootNode) {
      if (!window[globalKey]) {
        window[globalKey] = new Thredded;
      }
      window[globalKey].init(rootNode);
    } else {
      window[globalKey] = null;
    }
  });

})();
