class DocumentEmbeddingsModel
  def initialize(documentTextModel, embeddingsProvider)
    raise "documentTextModel is nil" if documentTextModel.nil?
    raise "embeddingsProvider is nil" if embeddingsProvider.nil?

    @documentTextModel = documentTextModel
    @embeddingsProvider = embeddingsProvider
  end

  #@embeddingsProvider.get_embeddings_for_text(text)

  # Returns an array of TextEmbeddingContainer representing the embeddings for every block of text
  #
  # @param model [String] The name of the model to use
  # @return [Array<TextEmbeddingContainer>] An array of TextEmbeddingContainer
  #
  def get_all_embeddings(model = nil)
    raise "Not implemented"
  end

  # Updates the embedding for the given identifier/block_index
  #
  # @param identifier [String] The identifier of the document
  # @param block_index [Integer] The index of the block
  # @param block [String] The text of the block
  # @param embedding_container_json [String] The json representation of the embedding container
  # @return [void]
  #
  private def update_embedding_container(identifier, block_index, block, embedding_container_json)
    # TextEmbeddingContainer.to_json
    # TextEmbeddingContainer.new(

    raise "Not implemented"
  end

  def get_embeddings_for_text(text, model = nil)
    @embeddingsProvider.get_embeddings_for_text(text, model)
  end
end
