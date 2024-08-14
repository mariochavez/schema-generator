require "uri"
require "net/http"

module SchemaGenerator
  class HTMLDownloader
    def self.download(url)
      uri = URI(url)
      response = Net::HTTP.get_response(uri)
      
      if response.is_a?(Net::HTTPSuccess)
        response.body
      else
        raise Error, "Failed to download HTML: #{response.code} #{response.message}"
      end
    end
  end
end
