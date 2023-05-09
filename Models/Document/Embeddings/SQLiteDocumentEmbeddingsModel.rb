class SQLiteDocumentEmbeddingsModel < DocumentEmbeddingsModel
  require "sqlite3" #SQLite3::

  def initialize(dbPath, documentTextModel, embeddingsProvider)
    @dbPath = dbPath
    create_table_if_not_exists()
    super(documentTextModel, embeddingsProvider)
  end

  # Create the table if it doesn't exist (called by initialize)
  #
  # @return [void]
  private def create_table_if_not_exists()
    SQLite3::Database.open(@dbPath) do |db|
      db.execute("CREATE TABLE IF NOT EXISTS embeddings (identifier TEXT, block_index INTEGER, block_text TEXT, embedding_container_json TEXT)")
    end
  end

  # Implement interface methods

  # Returns an array of TextEmbeddingContainer representing the embeddings for every block of text
  #
  # @param model [String] The name of the model to use
  # @return [Array<TextEmbeddingContainer>] An array of TextEmbeddingContainer
  #
  def get_all_embeddings(model = nil)
    raise "documentTextModel is nil" if @documentTextModel.nil?

    identifier = @documentTextModel.get_identifier()
    raise "Identifier is nil" if identifier.nil? || identifier.empty?

    puts "Getting embeddings for #{identifier}"
    embeddings = []
    SQLite3::Database.open(@dbPath) do |db|
      db.execute("SELECT embedding_container_json,block_text FROM embeddings WHERE identifier = ? ORDER BY block_index ASC", identifier) do |row|
        container = row[0].nil? ? nil : TextEmbeddingContainer.from_json(row[0])
        text = row[1]
        embeddings.push({ container: container, text: text })
      end
    end

    if embeddings.empty?
      puts "No embeddings found for #{identifier}, generating them now"
      initialize_embeddings() # build the table if it is empty
      return get_all_embeddings(model) # recursive, hopefully it doesn't blow up the stack
    end

    # If any embeddings are missing, generate them
    block_index = -1
    embeddings.each do |embedding|
      block_index += 1
      if embedding[:container].nil? || embedding[:container].embedding.nil?
        puts "Embedding missing for '#{embedding[:text]}', generating it now"

        # Get the embedding
        embeddingAsVector = @embeddingsProvider.get_embeddings_for_text(embedding[:text], model)
        #initialize(text, embedding, model, hash = nil)
        embeddingModel = model.nil? ? @embeddingsProvider.get_default_model_embeddings() : model
        embeddingObj = TextEmbeddingContainer.new(embedding[:text], embeddingAsVector, embeddingModel)

        update_embedding_container(identifier, block_index, embedding[:text], embeddingObj.to_json)

        embedding[:container] = embeddingObj # update our result
      end
    end

    puts "Done getting embeddings for #{identifier}"

    # Get all embedding[:container] that are not nil
    containers = embeddings.map { |embedding| embedding[:container] }.reject { |container| container.nil? }

    return containers
  end

  def initialize_embeddings()
    raise "documentTextModel is nil" if @documentTextModel.nil?

    identifier = @documentTextModel.get_identifier()
    # No embeddings found, so generate them
    allBlocks = @documentTextModel.get_text_blocks()
    raise "No blocks found for #{identifier} - did you call documentTextModel.build() ?" if allBlocks.nil? || allBlocks.empty?

    block_index = -1
    allBlocks.each do |block|
      block_index += 1 # Increment before the check so that the first block is 0
      if block.nil? || block.empty?
        puts "Skipping empty block #{block_index}"
      else
        update_embedding_container(identifier, block_index, block, nil) # Create a blank placeholder
      end
    end
  end

  private def update_embedding_container(identifier, block_index, block, embedding_container_json)
    raise "identifier is nil" if identifier.nil? || identifier.empty?
    raise "block_index must be >= 0" if block_index < 0
    raise "block is nil" if block.nil? || block.empty?

    #raise "embedding_container_json is nil" if embedding_container_json.nil?

    if (embedding_container_json.nil?)
      embedding_container_json = "" # This means it needs to be written later. Nil is ok as a param
    end

    if (!embedding_container_json.nil? && (embedding_container_json.is_a?(TextEmbeddingContainer) || !embedding_container_json.is_a?(String)))
      # Doing it wrong!
      raise "embedding_container_json is a TextEmbeddingContainer, not a string (did you forget to call to_json() ?)"
    end

    SQLite3::Database.open(@dbPath) do |db|
      #update if exists, insert if not
      # there are no primary keys, so we have to check for existence
      # update the embedding_container_json only

      db.execute("INSERT INTO embeddings (identifier, block_index, block_text, embedding_container_json) SELECT ?, ?, ?, ? WHERE NOT EXISTS(SELECT 1 FROM embeddings WHERE identifier = ? AND block_index = ?)", identifier, block_index, block, embedding_container_json, identifier, block_index)
      if db.changes == 0
        # Update
        db.execute("UPDATE embeddings SET embedding_container_json = ? WHERE identifier = ? AND block_index = ?", embedding_container_json, identifier, block_index)
      end
    end
  end
end
