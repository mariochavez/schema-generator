require "test_helper"

class SchemaGenerator::CLITest < Minitest::Test
  def setup
    @cli = SchemaGenerator::CLI.new
    @original_api_key = SchemaGenerator.configuration.api_key
  end

  def teardown
    SchemaGenerator.configuration.api_key = @original_api_key
    ENV["CLAUDE_API_KEY"] = nil
  end

  def test_generate_with_api_key_option
    SchemaGenerator::Generator.stub :generate, nil do
      @cli.options = {api_key: "test_key"}
      @cli.generate("https://example.com")
      assert_equal "test_key", SchemaGenerator.configuration.api_key
    end
  end

  def test_generate_without_api_key_option
    ENV["CLAUDE_API_KEY"] = "env_test_key"
    SchemaGenerator.configuration.api_key = nil

    SchemaGenerator::Generator.stub :generate, nil do
      @cli.options = {}
      @cli.generate("https://example.com")
      assert_equal "env_test_key", SchemaGenerator.configuration.api_key
    end
  end

  def test_generate_raises_error_without_api_key
    ENV["CLAUDE_API_KEY"] = nil
    SchemaGenerator.configuration.api_key = nil
    @cli.options = {}

    error = assert_raises SystemExit do
      stderr = capture_io do
        @cli.generate("https://example.com")
      end
      assert_match(/Claude API key not found/, stderr.join)
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
