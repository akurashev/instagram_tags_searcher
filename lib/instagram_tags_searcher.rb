# frozen_string_literal: true

require 'cgi'

require 'instagram_tags_searcher/http_client'

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
    tag = CGI.escape(tag)
    data = HttpClient.new.read_hash(
      "https://www.instagram.com/explore/tags/#{tag}/?__a=1"
    )

    moretags = []
    codes = []

    posts = data['graphql']['hashtag']['edge_hashtag_to_top_posts']['edges']
    posts.each do |post|
      begin
        text = post['node']['edge_media_to_caption']['edges'][0]['node']['text']
        words = text.split
      rescue StandardError
        codes << post['node']['shortcode']
        next
      end

      local_tags = search_tags(words)

      codes << post['node']['shortcode'] if local_tags.size < 30

      moretags += local_tags
    end

    [moretags.uniq, codes]
  end

  def self.from_first_comment(code)
    data = HttpClient.new.read_hash(
      "https://www.instagram.com/p/#{code}/?__a=1"
    )
    comments = data['graphql']['shortcode_media']['edge_media_to_parent_comment']

    comments_count = comments['count']

    if comments_count.positive?
      first_comment = comments['edges'][0]['node']['text'].split
      search_tags(first_comment)
    else
      []
    end
  end

  def self.sort_by_frequency(tags)
    low = []
    middle = []
    high = []

    tags.each do |tag|
      sleep(rand(1..4) * 0.1)

      posts_count = posts_count(tag)

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

  def self.posts_count(tag)
    tag_name = CGI.escape(tag[1..-1])
    url = "https://www.instagram.com/explore/tags/#{tag_name}/?__a=1"
    data = HttpClient.new.read_hash(url)

    posts = data['graphql']['hashtag']['edge_hashtag_to_media']
    posts['count'].to_i
  end

  def self.search_tags(words)
    words.select do |word|
      word.start_with?('#') && word.count('#') == 1 && word.length > 2
    end
  end
end
