# This file is the main file for the EmbeddingPromptedSearch module. It requires all the other files in the module.

# Directories to scan for files to require
dirs_to_scan = ["Containers", "Models", "AI"]

excluded = ["isolated_test_runner.rb"] # Files to exclude from being required

require_relative "Tests/test_helper.rb"

dirs_to_scan.each do |dir|
  # Require all files in the directory and subdirectories recursively
  Dir.glob(File.join(File.dirname(__FILE__), dir, "**", "*.rb")).each do |file|
    # Skip excluded files
    if excluded.include?(File.basename(file))
      next
    end

    # Don't load these files in non-testing
    if !$is_running_tests
      # Skip files that start with "test_"
      if File.basename(file).downcase.start_with?("test_")
        next
      end
    end

    # Load it up
    require file
  end
end

#    cool
