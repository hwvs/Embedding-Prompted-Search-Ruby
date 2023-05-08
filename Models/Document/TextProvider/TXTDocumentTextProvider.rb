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
end
