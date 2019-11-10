# frozen_string_literal: true

require 'instagram_tags_searcher/instagram/client'

module InstagramTagsSearcher
  def self.search(tag)
    tags, codes = top_tags(tag)

    codes.each do |code|
      tags += comment_tags(code)
    end

    low = []
    middle = []
    high = []

    tags.uniq.each_slice(30) do |slice|
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

  def self.top_tags(tag)
    tags = []
    codes = []

    posts = Instagram::Client.new.top(tag).posts
    posts.each do |post|
      begin
        text = post.text
      rescue StandardError
        codes << post.code
        next
      end

      found_tags = search_tags(text)

      codes << post.code if found_tags.size < 30

      tags += found_tags
    end

    [tags.uniq, codes]
  end

  def self.comment_tags(code)
    post = Instagram::Client.new.post(code)

    search_tags(post.first_comment_text)
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

  def self.search_tags(text)
    text.split.select do |word|
      word.start_with?('#') && word.count('#') == 1 && word.length > 2
    end
  end
end
