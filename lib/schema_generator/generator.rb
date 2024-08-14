require "yaml"

module SchemaGenerator
  class Generator
    def self.generate(url)
      domain = URI(url).host
      sitemap_url = "#{url}/sitemap.xml"
      urls = SitemapFetcher.fetch(sitemap_url)
      
      schemas = {}
      urls.each do |page_url|
        html = HTMLDownloader.download(page_url)
        schema = ClaudeAPIClient.generate_seo_schema(html)
        schemas[page_url] = JSON.parse(schema)
      end
      
      File.write("#{domain}_schemas.yaml", schemas.to_yaml)
      puts "Schemas saved to #{domain}_schemas.yaml"
    end
  end
end
