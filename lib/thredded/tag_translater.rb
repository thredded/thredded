module Thredded
  class TagTranslater
    attr_reader :post

    def initialize(post)
      @post = post
    end

    def self.replace_all_timg_tags
      old_delivery_method = ActionMailer::Base.delivery_method
      ActionMailer::Base.delivery_method = :test
      posts = Thredded::Post.where("content like '%[t:img%'")

      begin
        posts.each do |post|
          new(post).timg_to_image_tag
        end
      ensure
        ActionMailer::Base.delivery_method = old_delivery_method
      end
    end

    def timg_to_image_tag
      content = post.content
      matches = content.scan(/(?<full>\[t:(?<tag>\w+)=?(?<img_nmb>\d+)? ?(?<attribs>[^\]]+)?\])/)
      attachments = post.attachments

      matches.each_with_index do |timg, i|
        if attachments[i]
          full_tag = timg[0]
          url = attachments[i].attachment_url
          content = content.sub(full_tag, attachment_tag(url))
        end
      end

      post.update_attributes(content: content)
    end

    private

    def attachment_tag(url)
      if post.filter == 'bbcode'
        "[img]#{url}[/img]"
      else
        "![](#{url})"
      end
    end
  end
end
