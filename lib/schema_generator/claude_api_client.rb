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
        "Content-Type" => "application/json",
        "X-API-Key" => SchemaGenerator.configuration.api_key
      })

      prompt = <<~PROMPT
        Task: Parse the given HTML content and extract all useful information to create a structured SEO LD+JSON Schema.

        Instructions:
        1. Analyze the HTML content thoroughly.
        2. Identify key elements such as title, meta descriptions, headings, main content, images, and any other relevant SEO information.
        3. Based on the extracted information, create a comprehensive LD+JSON Schema that best represents the page content for SEO purposes.
        4. The output should be ONLY the LD+JSON Schema, without any additional explanation or description.
        5. Ensure the schema is valid JSON and follows the Schema.org vocabulary.

        HTML Content:
        #{html}

        Output the LD+JSON Schema:
      PROMPT

      request.body = {
        model: SchemaGenerator.configuration.model_name,
        prompt: prompt,
        max_tokens_to_sample: 2000,
        temperature: 0.2
      }.to_json

      response = http.request(request)

      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)["completion"]
      else
        raise SchemaGenerator::Error, "Failed to generate SEO schema: #{response.code} #{response.message}"
      end
    end
  end
end
