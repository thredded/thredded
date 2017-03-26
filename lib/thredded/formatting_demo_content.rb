# frozen_string_literal: true
module Thredded
  # Content for demo-ing formatting functionality
  module FormattingDemoContent
    class << self
      attr_accessor :parts
    end
    self.parts = [
      <<-'MARKDOWN',
#### Oneboxes

URLs of supported resources are replaced with boxes like these:

**Twitter** `https://twitter.com/thredded/status/838824533477982209`:
https://twitter.com/thredded/status/838824533477982209
**StackExchange** `http://codegolf.stackexchange.com/questions/45701`:
http://codegolf.stackexchange.com/questions/45701
**Amazon** `https://www.amazon.co.uk/dp/0521797071`:
https://www.amazon.co.uk/dp/0521797071
**YouTube** `https://www.youtube.com/watch?v=1QP7elXwpLw`:
https://www.youtube.com/watch?v=1QP7elXwpLw
**Google Maps** `https://goo.gl/maps/R6nj3Qwf2LR2`:
https://goo.gl/maps/R6nj3Qwf2LR2

Many more resources are [supported](https://github.com/discourse/onebox/tree/master/lib/onebox/engine). Powered by the [onebox](https://github.com/discourse/onebox) library.
      MARKDOWN
    ]
  end
end
