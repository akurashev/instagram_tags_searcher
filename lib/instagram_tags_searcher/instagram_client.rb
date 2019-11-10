# frozen_string_literal: true

require 'cgi'

require 'instagram_tags_searcher/http_client'

module InstagramTagsSearcher
  # This class is responsible for making requests to Instagram
  # It knows which URL should be used and which params should be passed
  class InstagramClient
    URL_TOP = 'https://www.instagram.com/explore/tags/%<param>s/?__a=1'
    URL_POST = 'https://www.instagram.com/p/%<param>s/?__a=1'

    def initialize(http_client = HttpClient.new)
      @http_client = http_client
    end

    def top(tag)
      @param = sanitize_tag(tag)
      @url_template = URL_TOP
      make_request
    end

    def post(code)
      @param = code
      @url_template = URL_POST
      make_request
    end

    private

    attr_reader :http_client, :url_template, :param

    def make_request
      http_client.read_hash(url)
    end

    def url
      format(url_template, param: param)
    end

    def sanitize_tag(tag)
      tag = tag[1..-1] if tag.start_with?('#')
      CGI.escape(tag)
    end
  end
end
