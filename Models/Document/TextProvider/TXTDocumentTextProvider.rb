class TXTDocumentTextProvider < DocumentTextProvider
  def initialize(txtPath)
    @txtPath = txtPath
  end

  def get_identifier()
    file_name = File.basename(@txtPath)
    file_size = File.size(@txtPath)

    return "#{file_name} (#{file_size} bytes)"
  end

  def get_fulltext()
    if @txtPath.nil?
      raise "TXT Path is nil"
    end

    # Get contents
    fulltext = File.read(@txtPath)

    # trim
    fulltext = fulltext.strip

    return fulltext
  end

  def self.can_handle_file?(filename = nil, file_extension = nil, file_mime_type = nil)
    # TODO: Actually check the file contents - We are just going to assume that the TXT handler
    #       can handle anything, because it is the lowest priority
    return true

    if !file_extension.nil?
      # If no mine and empty extension, assume text
      if (file_extension.empty?)
        return true
      end

      # Explicitly text
      if (file_extension.start_with?("txt") || file_extension.start_with?("text"))
        return true
      end

      exact_matches = ["md", "markdown", "csv", "tsv", "sh"]
      if (exact_matches.include?(file_extension))
        return true
      end
    end

    if !file_mime_type.nil?
      return file_mime_type.start_with?("application/text") || file_mime_type.start_with?("text/plain") || file_mime_type.start_with?("text/csv")
    end

    return false
  end

  def self.get_priority()
    return -9999 # absolute lowest priority - only if no other provider can handle the file
  end
end
