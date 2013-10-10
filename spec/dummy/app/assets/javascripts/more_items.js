/* 
 * Russ wants to refactor this to set it on a list
 * FUTURE USAGE:
 *   $('ul.news').more_items(urlToHit,pageNumber,buttonElement,loaderElement)
 */
var more_items = {
	videos_more: "/m/fake/videos_more.html",
	images_more: "/m/fake/images_more.html",
	news_more: "/m/fake/news_more.html",
	missions_more: "/m/fake/missions_more.html",
	news_page: 0,
	images_page: 0,
	missions_page: 0,
	videos_page: 0,

	getMoreItemsAndAppendTo: function(type, entry_selector){
		$('.loading').show();
		$('.more_button .button').hide();
		switch(type){
			case "news":
				this.news_page += 1;
				this.getSpecificPage(this.news_page, this.news_more, entry_selector)
				break;
			case "missions":
				this.missions_page += 1;
				this.getSpecificPage(this.missions_page, this.missions_more, entry_selector);
				break;
			case "images":
				this.images_page += 1;
				this.getSpecificPage(this.images_page, this.images_more, entry_selector);
				break;
			case "videos":
				this.videos_page += 1;
				request_data = {"page": this.videos_page}
				this.getSpecificPage(this.videos_page, this.videos_more, entry_selector);
				break;
			default:
			//do nothing
		}
	},

	getSpecificPage: function(page, url, entry_selector){
		request_data = {"page": page}
		$.get(url, request_data, function(data){
			entry_selector.after(data);
			$('.loading').hide();
			$('.more_button .button').show();
		})
	}

}