module Thredded
  class BaseTopicDecorator < SimpleDelegator
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    def slug
      __getobj__.slug.nil? ? id : __getobj__.slug
    end

    def original
      __getobj__
    end

    def updated_at_timeago
      if updated_at.nil?
        <<-eohtml.html_safe.strip_heredoc
          <abbr>
            a little while ago
          </abbr>
        eohtml
      else
        <<-eohtml.html_safe.strip_heredoc
          <abbr class="timeago" title="#{updated_at_utc}">
            #{updated_at_str}
          </abbr>
        eohtml
      end
    end

    def created_at_timeago
      if created_at.nil?
        <<-eohtml.html_safe.strip_heredoc
          <abbr class="started_at">
            a little while ago
          </abbr>
        eohtml
      else
        <<-eohtml.html_safe.strip_heredoc
          <abbr class="started_at timeago" title="#{created_at_utc}">
            #{created_at_str}
          </abbr>
        eohtml
      end
    end

    private

    def updated_at_str
      updated_at.to_s
    end

    def updated_at_utc
      updated_at.getutc.iso8601
    end

    def created_at_str
      created_at.to_s
    end

    def created_at_utc
      created_at.getutc.iso8601
    end
  end
end
