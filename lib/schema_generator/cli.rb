require "thor"

module SchemaGenerator
  class CLI < Thor
    class_option :api_key, type: :string, desc: 'Claude API key'

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
      if options[:api_key]
        SchemaGenerator.configure do |config|
          config.api_key = options[:api_key]
        end
      elsif SchemaGenerator.configuration.api_key.nil?
        if ENV['CLAUDE_API_KEY']
          SchemaGenerator.configure do |config|
            config.api_key = ENV['CLAUDE_API_KEY']
          end
        else
          raise SchemaGenerator::Error, "Claude API key not found. Please set CLAUDE_API_KEY environment variable or use --api_key option."
        end
      end
    end
  end
end
