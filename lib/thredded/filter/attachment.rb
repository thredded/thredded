module Thredded
  module Filter
    module Attachment
      def filtered_content
        content = super
        matches = content.scan(/(?<full>\[t:(?<tag>\w+)=?(?<img_nmb>\d+)? ?(?<attribs>[^\]]+)?\])/)

        matches.each do |match|
          str_buff = ''
          full = match[0]
          tag = match[1]
          img_number = match[2] ? match[2].to_i - 1 : 0 # default to first attachment
          attribs = match[3]

          if(tag != 'img' || !self.attachments[img_number])
            next
          end

          # start with img tag
          str_buff += '<img '

          # get attachment object at spot img_number - 1
          attachment = self.attachments[img_number]
          str_buff += 'src="' + attachment.attachment.to_s + '" '

          # do attribute stuff, left right first
          if !attribs.nil?
            if align = attribs.match(/(left|right)/)
              str_buff += 'class="align_' + align[0] + '" '
            end

            # attributes, width x height
            if wxh = attribs.match(/(\d+)x?(\d+)?/)
              str_buff += 'width="' + wxh[1] + '" '
              height = wxh[2].nil? ? wxh[1] : wxh[2]
              str_buff += 'height="' + height + '" '
            end
          end

          # end img tag
          str_buff += '/>'

          # replace in post content
          content = content.sub(full, str_buff)
        end

        content.html_safe
      end
    end
  end
end
