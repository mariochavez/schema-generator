require "test_helper"

class SchemaGeneratorTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::SchemaGenerator::VERSION
  end

  def test_configuration_returns_configuration_instance
    assert_instance_of SchemaGenerator::Configuration, SchemaGenerator.configuration
  end

  def test_configuration_memoization
    assert_same SchemaGenerator.configuration, SchemaGenerator.configuration
  end

  def test_configure_yields_configuration
    SchemaGenerator.configure do |config|
      assert_same SchemaGenerator.configuration, config
    end
  end

  def test_configure_allows_setting_api_key
    SchemaGenerator.configure { |config| config.api_key = "test_key" }
    assert_equal "test_key", SchemaGenerator.configuration.api_key
  end
end
