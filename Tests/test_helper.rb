require_relative "../EmbeddingPromptedSearch.rb"

# if rails
if defined?(Rails)
  DATABASE_PATH = "db/unit_testing.sqlite3"
else
  DATABASE_PATH = Tempfile.new(["unit_testing", ".sqlite3"]).path
end

# Check if testing is running
# Check if "bin/rails test"
if (!defined?($is_running_tests)) # If it's not defined, define it
  $is_running_tests = false
  ARGV.each do |arg|
    puts "arg = " + arg
    if arg == "test"
      $is_running_tests = true
    end
  end
end

if !$is_running_tests
  #raise "This file should only be required when running tests!"
else
  puts "~~~ Preparing EmbeddingPromptedSearch tests ~~~"

  #$test_filename = "storage/documents/2454180-2.pdf"
  #raise ("Test file does not exist (" + $test_filename + ")") if !File.exist?($test_filename)

  $test_filename = nil

  # Try to create with a test file
  if defined?(Rails)
    $test_filename = "storage/documents/2454180-2.pdf"
    if !File.exist?($test_filename)
      $test_filename = nil
    end
  end

  # Otherwise, create a temp file
  if $test_filename.nil?
    # Create a temp file (OS)
    $test_filename = Tempfile.new(["test"]).path + ".txt" # Adding .txt to the end so ruby doesn't auto-delete it

    puts "Creating test file: " + $test_filename

    # write "This is a test file."x500
    File.open($test_filename, "w") do |f|
      f.write("This is a test file. " * 500)
    end
  end

  raise "Test file does not exist (" + $test_filename + ")" if !File.exist?($test_filename)

  # Create a new document provider
  #$test_documentTextProvider = PDFDocumentTextProvider.new($test_filename)
  $test_documentTextProvider = DocumentTextProvider.get_provider_for_file($test_filename) # Detects file type, wow

  $test_sqliteDocumentTextModel = SQLiteDocumentTextModel.new(DATABASE_PATH, $test_documentTextProvider)
  #$test_sqliteDocumentTextModel.build()
  $test_openAICacheProvider = SQLiteOpenAICacheProvider.new(DATABASE_PATH)
  #$test_openAIProvider = OpenAIProvider.new($test_openAICacheProvider)
  $test_openAIProvider = MockOpenAIProvider.new($test_openAICacheProvider)
  $test_documentEmbeddingsModel = SQLiteDocumentEmbeddingsModel.new(DATABASE_PATH, $test_sqliteDocumentTextModel, $test_openAIProvider)
  $test_documentSearchModel = DocumentSearchModel.new($test_documentEmbeddingsModel)
end
