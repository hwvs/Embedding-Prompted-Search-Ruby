class PDFDocumentTextProvider < DocumentTextProvider
  require "rubygems"
  require "pdf/reader"

  def initialize(pdfPath)
    @pdfPath = pdfPath
  end

  def get_identifier()
    file_name = File.basename(@pdfPath)
    file_size = File.size(@pdfPath)

    return "#{file_name} (#{file_size} bytes)"
  end

  def get_fulltext()
    if @pdfPath.nil?
      raise "PDF Path is nil"
    end

    # Array of pages (text)
    pages = []

    PDF::Reader.open(@pdfPath) do |reader|
      reader.pages.each do |page|
        pages << page.text.strip
      end
    end

    # combine pages into one string
    fulltext = pages.join(" ")

    # trim
    fulltext = fulltext.strip

    return fulltext
  end

  def self.can_handle_file?(filename = nil, file_extension = nil, file_mime_type = nil)
    if !file_mime_type.nil?
      return file_mime_type.start_with?("application/pdf")
    end
    if !file_extension.nil?
      return file_extension.start_with?("pdf")
    end

    return false
  end

  def self.get_priority()
    return 100 # highest priority - exact match
  end
end
