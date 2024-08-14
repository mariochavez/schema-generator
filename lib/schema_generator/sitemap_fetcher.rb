require "uri"
require "net/http"
require "nokogiri"

module SchemaGenerator
  class SitemapFetcher
    def self.fetch(url)
      uri = URI(url)
      response = Net::HTTP.get_response(uri)
      
      if response.is_a?(Net::HTTPSuccess)
        doc = Nokogiri::XML(response.body)
        doc.xpath("//loc").map(&:text)
      else
        raise Error, "Failed to fetch sitemap: #{response.code} #{response.message}"
      end
    end
  end
end
