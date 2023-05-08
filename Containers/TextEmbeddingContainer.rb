class TextEmbeddingContainer
  def initialize(text, embedding, model, hash = nil)
    # Validation
    raise ArgumentError, "Text cannot be nil or empty" if text.nil? || text.empty?
    raise ArgumentError, "Embedding cannot be nil or empty! DoingItWrong!" if embedding.nil? || embedding.empty? # DoingItWrong. This is purely a data storage class.
    raise ArgumentError, "Model cannot be nil or empty" if model.nil? || model.empty?

    @text = text
    @embedding = embedding
    @model = model
    @hash = hash || calc_hash(embedding, model, text)
  end

  attr_reader :text, :embedding, :model, :hash

  def self.from_json(json)
    data = JSON.parse(json)
    new(data["text"], data["embedding"], data["model"], data["hash"])
  end

  def to_json
    {
      text: text,
      embedding: embedding,
      hash: hash,
      model: model,
    }.to_json
  end

  private def calc_hash(embedding, model, text)
    raise ArgumentError, "Text cannot be nil or empty" if text.nil? || text.empty?
    raise ArgumentError, "Embedding cannot be nil or empty! DoingItWrong!" if embedding.nil? || embedding.empty? # DoingItWrong. This is purely a data storage class.
    raise ArgumentError, "Model cannot be nil or empty" if model.nil? || model.empty?

    # Just to keep things simple, we'll actually only take the first 16 characters of the hash (8 Bytes)
    # This makes it shorter, and the chance of a collision is only 1 in 18,446,744,073,709,551,616 (aka: 0)
    hash = Digest::SHA256.hexdigest("#{embedding}~~~#{model}~~~#{text}")
    return hash[0..15].upcase # truncate + upper
  end
end
