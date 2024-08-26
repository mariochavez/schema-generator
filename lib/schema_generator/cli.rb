require "thor"
require "logger"

module SchemaGenerator
  class CLI < Thor
    class_option :api_key, type: :string, desc: "LLM API key"
    class_option :model_name, type: :string, desc: "Model name (default: claude-3-opus-20240229)"
    class_option :llm_provider, type: :string, desc: "LLM provider (openai, ollama, or claude)"
    class_option :service_url, type: :string, desc: "Custom service URL"
    class_option :exclude, type: :string, desc: "Comma-separated list of URLs to exclude"
    class_option :verbose, type: :boolean, desc: "Enable verbose logging"

    desc "generate URL", "Generate SEO schema for the given URL"
    def generate(url)
      setup_configuration
      Generator.generate(url)
    rescue SchemaGenerator::Error => e
      puts "Error: #{e.message}"
      exit(1)
    end

    private

    def setup_configuration
      SchemaGenerator.configure do |config|
        config.api_key = options[:api_key] if options[:api_key]
        config.model_name = options[:model_name] if options[:model_name]
        config.llm_provider = options[:llm_provider].to_sym if options[:llm_provider]
        config.service_url = options[:service_url] if options[:service_url]
        config.exclude_list = options[:exclude].split(",") if options[:exclude]
        
        if options[:verbose]
          config.logger = Logger.new(STDOUT)
          config.logger.level = Logger::DEBUG
        end
      end

      if SchemaGenerator.configuration.api_key.nil?
        raise SchemaGenerator::Error, "API key not found. Please set API_KEY environment variable or use --api_key option."
      end

      if SchemaGenerator.configuration.model_name.nil?
        raise SchemaGenerator::Error, "Model name not found. Please set MODEL_NAME environment variable or use --model_name option."
      end

      unless [:openai, :ollama, :claude].include?(SchemaGenerator.configuration.llm_provider)
        raise SchemaGenerator::Error, "Invalid LLM provider. Please choose openai, ollama, or claude."
      end

      SchemaGenerator.configuration.logger.debug("Configuration set up successfully") if options[:verbose]
    end
  end
end
