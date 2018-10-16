//= require thredded/core/on_page_load
//= require thredded/core/serialize_form

// Makes topics in the list appear read as soon as the topic link is clicked,
// iff the topic link leads to the last page of the topic.
(() => {
  const Thredded = window.Thredded;

  const COMPONENT_SELECTOR = '[data-thredded-topics]';
  const TOPIC_UNREAD_CLASS = 'thredded--topic-unread';
  const TOPIC_READ_CLASS = 'thredded--topic-read';
  const POSTS_COUNT_SELECTOR = '.thredded--topics--posts-count';

  function pageNumber(url) {
    const match = url.match(/\/page-(\d)$/);
    return match ? +match[1] : 1;
  }

  function totalPages(numPosts, postsPerPage) {
    return Math.ceil(numPosts / postsPerPage);
  }

  function getTopicNode(node) {
    do {
      node = node.parentNode;
    } while (node && node.tagName !== 'ARTICLE');
    return node;
  }

  function initTopicsList(topicsList) {
    const postsPerPage = +topicsList.getAttribute('data-thredded-topic-posts-per-page') || 25;
    topicsList.addEventListener('click', (evt) => {
      const link = evt.target;
      if (link.tagName !== 'A' || link.parentNode.tagName !== 'H1') return;
      const topic = getTopicNode(link);
      if (pageNumber(link.href) === totalPages(+topic.querySelector(POSTS_COUNT_SELECTOR).textContent, postsPerPage)) {
        topic.classList.add(TOPIC_READ_CLASS);
        topic.classList.remove(TOPIC_UNREAD_CLASS);
      }
    });
  }

  Thredded.onPageLoad(() => {
    Array.prototype.forEach.call(document.querySelectorAll(COMPONENT_SELECTOR), initTopicsList);
  });
})();
