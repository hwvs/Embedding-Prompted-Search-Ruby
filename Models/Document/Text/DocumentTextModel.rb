class DocumentTextModel
  def initialize(documentTextProvider)
    @documentTextProvider = documentTextProvider

    setup()
  end

  # Get the identifier - a unique string that identifies this document
  #
  # @return [String] The identifier
  def get_identifier()
    raise "documentTextProvider is nil" if @documentTextProvider.nil?
    return @documentTextProvider.get_identifier()
  end

  # Virtual methods
  private def setup()
    raise NotImplementedError, "Subclass must implement abstract method"
  end
  private def __get_text_blocks() # Actual implementation
    raise NotImplementedError, "Subclass must implement abstract method"
  end
  private def __store_text_blocks(text_blocks) # Actual implementation
    raise NotImplementedError, "Subclass must implement abstract method"
  end

  # Get text blocks - This method caches the results
  #
  # @return [Array<String>] The text blocks
  def get_text_blocks() # This method returns the cached results, or passes it to the real implementation (__get_text_blocks)
    if @text_blocks.nil?
      @text_blocks = __get_text_blocks() # Get result and cache
    end
    return @text_blocks # Return cached
  end

  def build()
    if @documentTextProvider.nil?
      raise "DocumentTextProvider not set"
    end

    fulltext = @documentTextProvider.get_fulltext()
    if fulltext.nil?
      raise "Fulltext is nil"
    end

    build_from_fulltext(fulltext) # Pass to the builder
  end

  # Build the text blocks from the fulltext
  #
  # @param [String] fulltext The fulltext
  # @return [void]
  private def build_from_fulltext(fulltext)
    puts "Building text blocks for #{get_identifier()}"
    @text_blocks = grab_text_blocks_from_fulltext(fulltext)
    if @text_blocks.nil? || @text_blocks.empty?
      raise "Error, @text_blocks is empty in result from :grab_text_blocks_from_fulltext !"
    end
    __store_text_blocks(@text_blocks) # Save it
  end

  # Grabs blocks (paragraphs) of text from the fulltext
  #
  # @param [String] fulltext The fulltext
  # @param [Integer] block_max_words The maximum number of words per block
  # @param [Integer] block_max_chars The maximum number of characters per block
  # @param [Integer] max_stride_size The maximum stride size
  # @return [Array<String>] The text blocks
  private def grab_text_blocks_from_fulltext(fulltext, block_max_words = 512, block_max_chars = 2048, max_stride_size = -1)
    if max_stride_size == -1
      max_stride_size = (block_max_words / 2).floor
    end

    blocks = []

    # For now just grab 512-word blocks
    cur_block = ""
    cur_words = 0
    pattern = /(?<=[.?!])\s+(?=[A-Z])/
    fulltext.gsub(/\s{3,}/, " ").split(pattern).each do |sentence|
      num_words = sentence.split(" ")
      if cur_words + num_words.length > block_max_words || cur_block.strip.length + sentence.strip.length > block_max_chars
        newblock = cur_block.strip
        if newblock.length > 0
          blocks << newblock
        end
        cur_block = ""
        cur_words = 0
      end

      cur_block += sentence + " "
      cur_words += num_words.length
    end

    # Add the last block
    newblock = cur_block.strip
    if newblock.length > 0
      blocks << newblock
    end

    return blocks
  end
end
