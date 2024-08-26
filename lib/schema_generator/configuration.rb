module SchemaGenerator
  class Configuration
    attr_accessor :api_key, :model_name, :llm_provider, :service_url, :exclude_list

    def initialize
      @api_key = ENV["API_KEY"]
      @model_name = ENV["MODEL_NAME"] || "claude-3-opus-20240229"
      @llm_provider = (ENV["LLM_PROVIDER"] || :claude).to_sym
      @service_url = ENV["SERVICE_URL"]
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
