module Thredded
  class PostDecorator < SimpleDelegator
    attr_reader :post

    def initialize(post)
      super
      @post = post
    end

    def user_name
      if user
        user.to_s
      else
        'Anonymous'
      end
    end

    def user_link
      if post.user
        user_path = Thredded.user_path(post.user)
        "<a href='#{user_path}'>#{post.user}</a>".html_safe
      else
        '<a href="#">?</a>'.html_safe
      end
    end

    def original
      post
    end

    def created_at_timeago
      if created_at.nil?
        <<-eohtml.strip_heredoc.html_safe
          <abbr>
            a little while ago
          </abbr>
        eohtml
      else
        <<-eohtml.strip_heredoc.html_safe
          <abbr class="timeago" title="#{created_at_utc}">
            #{created_at_str}
          </abbr>
        eohtml
      end
    end

    def avatar_url
      super.sub(/\Ahttp:/, '')
    end

    private

    def created_at_str
      created_at.getutc.to_s
    end

    def created_at_utc
      created_at.getutc.iso8601
    end
  end
end
