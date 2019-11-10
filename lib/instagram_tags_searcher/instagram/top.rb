# frozen_string_literal: true

require 'instagram_tags_searcher/instagram/top_posts'

module InstagramTagsSearcher
  module Instagram
    # This class represents an Instagram Top page.
    # It's responsible for fetching any data from that page
    # like list of posts, posts count, etc.
    # It's aware of raw Instagram data structure.
    class Top
      def initialize(data)
        @data = data
      end

      def posts_count
        @data['graphql']['hashtag']['edge_hashtag_to_media']['count'].to_i
      end

      def posts
        TopPosts.new(
          @data['graphql']['hashtag']['edge_hashtag_to_top_posts']['edges']
        )
      end
    end
  end
end
