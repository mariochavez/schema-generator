require "uri"
require "net/http"
require "json"

module SchemaGenerator
  class OpenAICompatibleClient
    def self.generate_seo_schema(html)
      config = SchemaGenerator.configuration
      uri = URI(config.service_url || default_service_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")

      request = Net::HTTP::Post.new(uri.path, {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{config.api_key}"
      })

      prompt = create_prompt(html)

      request.body = {
        model: config.model_name,
        messages: [{role: "user", content: prompt}]
      }.to_json

      response = http.request(request)

      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)["choices"][0]["message"]["content"].strip
      else
        raise Error, "Failed to generate SEO schema: #{response.code} #{response.message}"
      end
    end

    private

    def self.default_service_url
      case SchemaGenerator.configuration.llm_provider
      when :openai
        "https://api.openai.com/v1/chat/completions"
      when :ollama
        "http://localhost:11434/api/chat"
      else
        raise Error, "Unsupported LLM provider for OpenAI-compatible client"
      end
    end

    def self.create_prompt(html)
      <<~PROMPT
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
    end
  end
end
