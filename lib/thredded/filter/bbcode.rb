module Thredded
  module Filter
    module Bbcode
      require 'bb-ruby'

      BB = {
        'Spoilers' => [
          /\[spoiler\](.*?)\[\/spoiler\1?\]/mi,
          '<blockquote class="spoiler">\1</blockquote>',
          'Spoiler Text',
          '[spoiler]Dumbledore dies[/spoiler]',
          :spoiler],
        'YouTube' => [
          /\[youtube\]https?\:\/\/(www\.)?youtube.com\/((watch)?\?vi?=|embed\/)(.*?)\[\/youtube\1?\]/i,
          '<iframe class="youtube" width="560" height="315" src="//www.youtube.com/embed/\4?&rel=0&theme=light&showinfo=0&hd=1&autohide=1&color=white" frameborder="0" allowfullscreen="allowfullscreen"></iframe>',
          'Youtube Video',
          :video],
        'Link (Legacy)' => [
          /\[link=(?:&quot;)?(.*?)(?:&quot;)?\](.*?)\[\/link\]/mi,
          '<a href="\1">\2</a>',
          'Hyperlink to somewhere else',
          'Maybe try looking on [link=http://google.com]Google[/link]?',
          :link],
        'Link (Legacy Implied)' => [
          /\[link\](.*?)\[\/link\]/mi,
          '<a href="\1">\1</a>',
          'Hyperlink (legacy implied)',
          "Maybe try looking on [link]http://google.com[/link]",
          :link],
      }

      def self.included(base)
        base.class_eval do
          Thredded::Post::Filters << :bbcode
        end
      end

      def filtered_content
        if filter.to_sym == :bbcode
          content = super
          content = replace_code_tags(content)
          content = replace_quote_tags(content)
          content = content.bbcode_to_html(BB)
          content = remove_empty_p_tags(content)
          content = CGI.unescapeHTML(content)

          content.html_safe
        else
          super
        end
      end

      def replace_code_tags(content)
        content.gsub!(/\[code\]/, '<pre><code>')
        content.gsub!(/\[code:(\D+?)\]/, '<pre><code class="language-\1" lang="\1">')
        content.gsub!(/\[\/code\]/, '</code></pre>')
        content.html_safe
      end

      def replace_quote_tags(content)
        content.gsub!(/\[quote(:.*)?=(?:&quot;)?(.*?)(?:&quot;)?\]/,
          '</p><fieldset><legend>\2</legend><blockquote><p>')
        content.gsub!(/\[quote(:.*?)?\]/,
          '</p><fieldset><blockquote><p>')
        content.gsub!(/\[\/quote\]/,
          '</p></blockquote></fieldset><p>')
        content.html_safe
      end

      def remove_empty_p_tags(content)
        content.gsub(/&lt;p&gt;\s*?&lt;\/p&gt;/, '')
      end
    end
  end
end
