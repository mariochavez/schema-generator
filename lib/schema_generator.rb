require "logger"
require "schema_generator/version"
require "schema_generator/configuration"
require "schema_generator/cli"
require "schema_generator/sitemap_fetcher"
require "schema_generator/html_downloader"
require "schema_generator/claude_api_client"
require "schema_generator/generator"

module SchemaGenerator
  class Error < StandardError; end
  # Your code goes here...
end
