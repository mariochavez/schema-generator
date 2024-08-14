module SchemaGenerator
  class Configuration
    attr_accessor :api_key

    def initialize
      @api_key = ENV['CLAUDE_API_KEY']
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
