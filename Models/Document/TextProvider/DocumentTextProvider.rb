class DocumentTextProvider
    def get_fulltext()
      raise NotImplementedError, "Subclass must implement abstract method"
    end
  
    def get_identifier()
      raise NotImplementedError, "Subclass must implement abstract method"
    end
  end