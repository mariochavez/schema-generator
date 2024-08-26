require "yaml"

module SchemaGenerator
  class Generator
    def self.generate(url)
      domain = URI(url).host
      sitemap_url = "#{url}/sitemap.xml"
      urls = SitemapFetcher.fetch(sitemap_url).reject do |url|
        SchemaGenerator.configuration.exclude_list.any? { |filter| url.include?(filter) }
      end

      schemas = {}
      urls.each do |page_url|
        html = HTMLDownloader.download(page_url)
        schema = case SchemaGenerator.configuration.llm_provider
        when :claude
          ClaudeAPIClient.generate_seo_schema(html)
        when :openai, :ollama
          OpenAICompatibleClient.generate_seo_schema(html)
        else
          raise Error, "Unsupported LLM provider"
        end
        schemas[page_url] = JSON.parse(schema)
      end

      File.write("#{domain}_schemas.yaml", schemas.to_yaml)
      puts "Schemas saved to #{domain}_schemas.yaml"
    end
  end
end
