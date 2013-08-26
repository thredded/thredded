module Thredded
  class PostDecorator < SimpleDelegator
    attr_reader :post

    def initialize(post)
      super
      @post = post
    end

    def user_name
      if user
        user.name
      else
        'Anonymous'
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

    def gravatar_url
      super.gsub /http:/, ''
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
