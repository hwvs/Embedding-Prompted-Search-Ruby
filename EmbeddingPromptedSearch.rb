# This file is the main file for the EmbeddingPromptedSearch module. It requires all the other files in the module.

# Directories to scan for files to require
dirs_to_scan = ["Containers", "Models"]

excluded = ["test_helper.rb", "Test_SQLiteDocumentEmbeddingsModel.rb"]

dirs_to_scan.each do |dir|
  # Require all files in the directory and subdirectories recursively
  Dir.glob(File.join(File.dirname(__FILE__), dir, "**", "*.rb")).each do |file|
    # Skip excluded files
    if excluded.include?(File.basename(file))
      next
    end

    # Load it up
    require file
  end
end

require_relative "OpenAIProvider.rb"

#    cool
