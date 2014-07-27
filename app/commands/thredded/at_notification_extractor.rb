module Thredded
  class AtNotificationExtractor
    def initialize(content)
      @content = content
    end

    def run
      scanned_names = @content.scan(/@([\w]+)(\W)?/)
      scanned_names += @content.scan(/@"([\w\ ]+)"(\W)?/)
      scanned_names
        .map(&:first)
        .uniq
    end
  end
end
