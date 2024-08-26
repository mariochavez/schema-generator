require 'logger'

module SchemaGenerator
  class Configuration
    attr_accessor :api_key, :model_name, :llm_provider, :service_url, :exclude_list, :logger

    def initialize
      @api_key = ENV["API_KEY"]
      @model_name = ENV["MODEL_NAME"] || "claude-3-opus-20240229"
      @llm_provider = (ENV["LLM_PROVIDER"] || :claude).to_sym
      @service_url = ENV["SERVICE_URL"]
      @logger = default_logger
    end

    def logger=(new_logger)
      @logger = new_logger || default_logger
    end

    private

    def default_logger
      logger = Logger.new(File::NULL)
      logger.level = Logger::WARN
      logger
    end

    def reset_logger
      @logger = default_logger
    end
  end

  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
