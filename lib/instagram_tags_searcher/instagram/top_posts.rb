# frozen_string_literal: true

require 'instagram_tags_searcher/instagram/top_post'

module InstagramTagsSearcher
  module Instagram
    # This is just an Enumerable wrapper around array of raw Top Posts items.
    # It wraps each raw item with TopPost class.
    class TopPosts
      include Enumerable

      def initialize(raw_posts)
        @raw_posts = raw_posts
      end

      def each
        @raw_posts.each do |post|
          yield TopPost.new(post)
        end
      end
    end
  end
end
