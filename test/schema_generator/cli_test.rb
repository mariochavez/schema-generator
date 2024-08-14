# test/schema_generator/cli_test.rb
require "test_helper"
require "stringio"

class SchemaGenerator::CLITest < Minitest::Test
  def setup
    @cli = SchemaGenerator::CLI.new
    @original_config = SchemaGenerator.configuration.dup
    @original_env = ENV.to_h
  end

  def teardown
    SchemaGenerator.configuration = @original_config
    ENV.clear
    ENV.update(@original_env)
  end

  def test_generate_with_all_options
    SchemaGenerator::Generator.stub :generate, nil do
      puts "++++++++++++++++++++++++++++++++"
      puts @cli.options.inspect
      @cli.options = {
        api_key: "test_key",
        model_name: "test-model",
        llm_provider: "openai",
        service_url: "https://test.com/api"
      }
      @cli.generate("https://example.com")
      config = SchemaGenerator.configuration
      puts "&&&& #{config.inspect}"
      assert_equal "test_key", config.api_key
      assert_equal "test-model", config.model_name
      assert_equal :openai, config.llm_provider
      assert_equal "https://test.com/api", config.service_url
    end
  end

  def test_generate_with_env_variables
    ENV["API_KEY"] = "test_key"
    ENV["MODEL_NAME"] = "test-model"
    ENV["LLM_PROVIDER"] = "ollama"
    ENV["SERVICE_URL"] = "http://localhost:11434"

    SchemaGenerator::Generator.stub :generate, nil do
      @cli.options = {}
      @cli.generate("https://example.com")
      config = SchemaGenerator.configuration
      assert_equal "test_key", config.api_key
      assert_equal "test-model", config.model_name
      assert_equal :ollama, config.llm_provider
      assert_equal "http://localhost:11434", config.service_url
    end
  end

  def test_generate_raises_error_with_invalid_llm_provider
    @cli.options = {llm_provider: "invalid", api_key: "test_key"}
    error = assert_raises SystemExit do
      capture_io do
        @cli.generate("https://example.com")
      end
    end
    assert_equal 1, error.status
  end

  def test_generate_raises_error_without_api_key
    ENV["API_KEY"] = nil
    SchemaGenerator.configuration.api_key = nil
    @cli.options = {}

    error = assert_raises SystemExit do
      _, stderr = capture_io do
        @cli.generate("https://example.com")
      end
      assert_match(/API key not found/, stderr)
    end
    assert_equal 1, error.status
  end

  private

  def capture_io
    captured_stdout, captured_stderr = StringIO.new, StringIO.new
    orig_stdout, orig_stderr = $stdout, $stderr
    $stdout, $stderr = captured_stdout, captured_stderr
    yield
    [captured_stdout.string, captured_stderr.string]
  ensure
    $stdout, $stderr = orig_stdout, orig_stderr
  end
end
