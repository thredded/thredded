(($) => {
  const COMPONENT_SELECTOR = '[data-thredded-topics]';

  const TOPIC_SELECTOR = 'article';
  const TOPIC_LINK_SELECTOR = 'h1 a';
  const TOPIC_UNREAD_CLASS = 'thredded--topic-unread';
  const TOPIC_READ_CLASS = 'thredded--topic-read';
  const POSTS_COUNT_SELECTOR = '.thredded--topics--posts-count';
  const POSTS_PER_PAGE = 50;

  function pageNumber(url) {
    const match = url.match(/\/page-(\d)$/);
    return match ? +match[1] : 1;
  }

  function totalPages(numPosts) {
    return Math.ceil(numPosts / POSTS_PER_PAGE);
  }

  class ThreddedTopics {
    init($nodes) {
      $nodes.on('click', TOPIC_LINK_SELECTOR, (evt) => {
        const $topic = $(evt.target).closest(TOPIC_SELECTOR);
        if (pageNumber($topic.find('a').prop('href')) == totalPages(+$topic.find(POSTS_COUNT_SELECTOR).text())) {
          $topic.addClass(TOPIC_READ_CLASS).removeClass(TOPIC_UNREAD_CLASS);
        }
      });
    }
  }

  window.Thredded.onPageLoad(() => {
    const $nodes = $(COMPONENT_SELECTOR);
    if ($nodes.length) {
      new ThreddedTopics().init($nodes);
    }
  });
})(jQuery);
