require "uri"
require "net/http"
require "json"

module SchemaGenerator
  class ClaudeAPIClient
    API_URL = "https://api.anthropic.com/v1/completions"

    def self.generate_seo_schema(html)
      uri = URI(API_URL)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.path, {
        'Content-Type' => 'application/json',
        'X-API-Key' => SchemaGenerator.configuration.api_key
      })

      request.body = {
        model: "claude-3-opus-20240229",
        prompt: "Generate SEO Schema for this HTML:\n\n#{html}\n\nReturn only the JSON schema.",
        max_tokens_to_sample: 1000
      }.to_json

      response = http.request(request)
      
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)["completion"]
      else
        raise Error, "Failed to generate SEO schema: #{response.code} #{response.message}"
      end
    end
  end
end
