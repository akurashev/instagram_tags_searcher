# frozen_string_literal: true

require 'json'
require 'open-uri'

module InstagramTagsSearcher
  # This is a simple HTTP client which relies on Ruby StdLib OpenURI module:
  # https://ruby-doc.org/stdlib-2.6.3/libdoc/open-uri/rdoc/OpenURI.html
  #
  # This wrapper supports custom User-Agent header values.
  # It expects JSON in response.
  class HttpClient
    HEADER = {
      'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; WOW64) ' \
                      'AppleWebKit/537.36 (KHTML, like Gecko) ' \
                      'Chrome/53.0.2785.104 Safari/537.36 Core/1.53.3357.400 ' \
                      'QQBrowser/9.6.11858.400'
    }.freeze

    def read_hash(url)
      JSON.parse(make_request(url))
    end

    private

    def make_request(url)
      URI.parse(url).open(HEADER).read
    end
  end
end
