# frozen_string_literal: true

require 'instagram_tags_searcher/instagram/client'

module InstagramTagsSearcher
  def self.search(tag)
    new_tags, codes = from_top(tag)

    if codes.count.positive?
      codes.each do |code|
        more_tags = from_first_comment(code)
        new_tags += more_tags
      end
    end

    new_tags = new_tags.uniq

    low = []
    middle = []
    high = []

    new_tags.each_slice(30) do |slice|
      l, m, h = sort_by_frequency(slice)

      low += l
      middle += m
      high += h

      sleep 60
    end

    {
      low: low,
      middle: middle,
      high: high
    }
  end

  def self.from_top(tag)
    posts = Instagram::Client.new.top(tag).posts

    moretags = []
    codes = []

    posts.each do |post|
      begin
        words = post.text.split
      rescue StandardError
        codes << post.code
        next
      end

      local_tags = search_tags(words)

      codes << post.code if local_tags.size < 30

      moretags += local_tags
    end

    [moretags.uniq, codes]
  end

  def self.from_first_comment(code)
    post = Instagram::Client.new.post(code)

    search_tags(post.first_comment_text.split)
  end

  def self.sort_by_frequency(tags)
    low = []
    middle = []
    high = []

    tags.each do |tag|
      sleep(rand(1..4) * 0.1)

      posts_count = Instagram::Client.new.top(tag).posts_count

      case posts_count
      when (10_001..100_000)
        low << tag
      when (100_001..1_000_000)
        middle << tag
      when (1_000_001..20_000_000)
        high << tag
      end
    rescue StandardError
      next
    end

    [low, middle, high]
  end

  def self.search_tags(words)
    words.select do |word|
      word.start_with?('#') && word.count('#') == 1 && word.length > 2
    end
  end
end
