# frozen_string_literal: true
module Thredded
  class SearchParser
    def initialize(query)
      @query = query
      @keywords = %w(in by order)
    end

    def parse
      parsed_input = parse_keywords
      parsed_input['text'] = parse_text
      parsed_input
    end

    def parse_keywords
      found_terms_hash = {}

      @keywords.each do |keyword|
        regex = Regexp.new(keyword + '\s*:\s*\w+', Regexp::IGNORECASE)
        keyword_scan = @query.scan(regex)
        @query = @query.gsub(regex, '')

        if keyword_scan.present?
          keyword_scan.each do |term|
            keyword_term = term.delete(' ').split(':')

            if found_terms_hash[keyword].nil?
              found_terms_hash[keyword] = []
            end

            found_terms_hash[keyword] << keyword_term[1]
          end
        end
      end

      found_terms_hash
    end

    def parse_text
      regex = Regexp.new('\"[^"]*\"')
      found_terms = @query.scan(regex)
      @query = @query.sub(regex, '')
      found_terms.concat(@query.split(/\s+/))
    end
  end
end
