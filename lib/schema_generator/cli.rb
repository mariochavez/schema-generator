require "thor"

module SchemaGenerator
  class CLI < Thor
    class_option :api_key, type: :string, desc: "LLM API key"
    class_option :model_name, type: :string, desc: "Model name (default: claude-3-opus-20240229)"
    class_option :llm_provider, type: :string, desc: "LLM provider (openai, ollama, or claude)"
    class_option :service_url, type: :string, desc: "Custom service URL"

    desc "generate URL", "Generate SEO schema for the given URL"
    def generate(url)
      setup_api_key
      Generator.generate(url)
    rescue SchemaGenerator::Error => e
      puts "Error: #{e.message}"
      exit(1)
    end

    private

    def setup_api_key
      SchemaGenerator.configure do |config|
        config.api_key = options[:api_key] if options[:api_key]
        config.model_name = options[:model_name] if options[:model_name]
        config.llm_provider = options[:llm_provider].to_sym if options[:llm_provider]
        config.service_url = options[:service_url] if options[:service_url]
      end

      if SchemaGenerator.configuration.api_key.nil?
        raise SchemaGenerator::Error, "API key not found. Please set API_KEY environment variable or use --api_key option."
      end

      unless [:openai, :ollama, :claude].include?(SchemaGenerator.configuration.llm_provider)
        raise SchemaGenerator::Error, "Invalid LLM provider. Please choose openai, ollama, or claude."
      end
    end
  end
end
