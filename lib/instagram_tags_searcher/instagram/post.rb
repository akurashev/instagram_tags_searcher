# frozen_string_literal: true

module InstagramTagsSearcher
  module Instagram
    # This class represents an Instagram Post.
    # It's responsible for fetching post data, like comments, etc.
    # It's aware of raw Instagram data structure
    class Post
      def initialize(data)
        @data = data
      end

      def first_comment_text
        return '' if comments_count.zero?

        comments['edges'][0]['node']['text']
      end

      private

      def comments_count
        comments['count']
      end

      def comments
        @data['graphql']['shortcode_media']['edge_media_to_parent_comment']
      end
    end
  end
end
