# frozen_string_literal: true

module InstagramTagsSearcher
  module Instagram
    # This class represents an Instagram Top Post.
    # It differs from a regular Post fetched by code.
    # It's aware of raw Instagram data structure.
    class TopPost
      def initialize(data)
        @data = data
      end

      def text
        @data['node']['edge_media_to_caption']['edges'][0]['node']['text']
      end

      def code
        @data['node']['shortcode']
      end
    end
  end
end
