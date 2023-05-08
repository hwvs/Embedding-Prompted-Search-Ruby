require_relative "EmbeddingPromptedSearch.rb"

DATABASE_PATH = "db/unit_testing.sqlite3"

# Check if testing is running
# Check if "bin/rails test"

$is_running_tests = false
ARGV.each do |arg|
  if arg == "test"
    $is_running_tests = true
  end
end

if !$is_running_tests
  #raise "This file should only be required when running tests!"
else
  puts "~~~ Preparing EmbeddingPromptedSearch tests ~~~"

  $test_filename = "storage/documents/2454180-2.pdf"
  raise ("Test file does not exist (" + $test_filename + ")") if !File.exist?($test_filename)

  # Create a new document provider
  $test_documentTextProvider = PDFDocumentTextProvider.new($test_filename)

  $test_sqliteDocumentTextModel = SQLiteDocumentTextModel.new(DATABASE_PATH, $test_documentTextProvider)
  #$test_sqliteDocumentTextModel.build()
  $test_openAICacheProvider = SQLiteOpenAICacheProvider.new(DATABASE_PATH)
  $test_openAIProvider = OpenAIProvider.new($test_openAICacheProvider)
  $test_documentEmbeddingsModel = SQLiteDocumentEmbeddingsModel.new(DATABASE_PATH, $test_sqliteDocumentTextModel, $test_openAIProvider)
  $test_documentSearchModel = DocumentSearchModel.new($test_documentEmbeddingsModel)
end