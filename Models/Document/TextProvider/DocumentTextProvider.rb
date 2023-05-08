class DocumentTextProvider
  def initialize(filename = nil)
    raise NotImplementedError, "Subclass must implement abstract method"
  end

  # Returns a string which represents the entire text of the document
  #
  # @return [String] The full text of the document
  #
  def get_fulltext()
    raise NotImplementedError, "Subclass must implement abstract method"
  end

  # Returns a string which represents a unique identifier for the document
  #
  # @return [String] The identifier of the document
  #
  def get_identifier()
    raise NotImplementedError, "Subclass must implement abstract method"
  end

  # Static method which returns a new instance of a provider for the given file, based on the file extension
  #
  # @param filename [String] The filename to check
  # @param file_extension [String] The file extension to check
  # @param file_mime_type [String] The mime type to check
  # @return [DocumentTextProvider] A new instance of a provider (child class of DocumentTextProvider)
  #
  def self.get_provider_for_file(filename = nil, file_extension = nil, file_mime_type = nil)
    if filename.nil? && file_extension.nil? && file_mime_type.nil?
      raise "At least one of filename, file_extension or file_mime_type must be provided"
    end
    if !filename.nil? && file_extension.nil? && file_mime_type.nil? # Filename, but no extension or mime type. Let's try to get it from the filename
      file_extension = File.extname(filename)

      begin
        # Check if MIME:: exists
        if !defined?(MIME::Types)
          # Include the gem
          require "mime/types"
        end

        file_mime_type = MIME::Types.type_for(filename).first.content_type
      rescue
        file_mime_type = nil # If we can't get the mime type, just set it to nil
      end
    end

    # Helper: Trim the file extension, downcase it, remove the dot
    file_extension_trimmed = file_extension.nil? ? nil : file_extension.downcase.strip.gsub(".", "")
    file_mime_type_trimmed = file_mime_type.nil? ? nil : file_mime_type.downcase.strip #.gsub(".", "")

    # Find the first provider that can handle the file
    all_providers = self.get_all_providers()

    # Sort providers by priority - bigger number = higher priority
    all_providers.sort_by! { |provider| provider.get_priority() }.reverse!

    # === Print Debug ===
    puts "Finding document provider for " + filename.to_s + " (" + file_extension_trimmed.to_s + ", " + file_mime_type_trimmed.to_s + ")"
    all_providers.each { |provider| puts provider.name + " (Priority=" + provider.get_priority().to_s + ")" } # Debug
    # === End debug ===

    provider = all_providers.find {
      |provider|
      provider.can_handle_file?(filename, file_extension_trimmed, file_mime_type_trimmed)
    }

    if provider.nil?
      raise "No provider found for file"
    end

    return provider.new(filename)
  end

  # Static class that returns all provider classes that inherit from DocumentTextProvider
  #
  # @return [Array<Class>] An array of classes
  #
  def self.get_all_providers()
    # Get all classes that inherit from this class
    return ObjectSpace.each_object(Class).select { |klass| klass < self }
  end

  # Checks if a specific file-type can be handled by this provider - Override this method in subclasses
  #
  # @param filename [String] The filename to check
  # @return [Boolean] True if the file can be handled, false otherwise
  #
  def self.can_handle_file?(filename = nil, file_extension = nil, file_mime_type = nil)
    # TODO: Implement this - use this to be able to select the correct provider for a file

    if filename.nil? && file_extension.nil? && file_mime_type.nil?
      raise "At least one of filename, file_extension or file_mime_type must be provided"
    end

    raise NotImplementedError, "Subclass must implement abstract method"
  end

  # Returns the priority of this provider (0-100, higher goes first) - Override this method in subclasses (def self.get_priority)
  #
  # @return [Integer] The priority of this provider
  #
  def self.get_priority()
    raise NotImplementedError, "Subclass must implement abstract method get_priority()"
  end
end
