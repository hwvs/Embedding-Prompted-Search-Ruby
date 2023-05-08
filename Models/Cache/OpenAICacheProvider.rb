class OpenAICacheProvider
  STR_USAGE_EMEDDING = "embedding"
  STR_USAGE_TOKENS = "tokens"
  STR_USAGE_COMPLETION = "completion"

  def get_embeddings_for_text(text, model)
    # check the params are valid
    raise ArgumentError, "Text cannot be nil or empty" if text.nil? || text.empty?
    raise ArgumentError, "Model cannot be nil or empty" if model.nil? || model.empty?

    return get_value(STR_USAGE_EMEDDING, model, text)
  end

  def set_embeddings_for_text(text, model, result)
    # check the params are valid
    raise ArgumentError, "Text cannot be nil or empty" if text.nil? || text.empty?
    raise ArgumentError, "Model cannot be nil or empty" if model.nil? || model.empty?
    raise ArgumentError, "Result cannot be nil or empty" if result.nil? || result.empty?

    put_value(STR_USAGE_EMEDDING, model, text, result) # We can overwrite it, no issue.
  end

  def get_completion_for_text(text, model)
    # check the params are valid
    raise ArgumentError, "Text cannot be nil or empty" if text.nil? || text.empty?
    raise ArgumentError, "Model cannot be nil or empty" if model.nil? || model.empty?

    return get_value(STR_USAGE_COMPLETION, model, text)
  end

  def set_completion_for_text(text, model, result)
    # check the params are valid
    raise ArgumentError, "Text cannot be nil or empty" if text.nil? || text.empty?
    raise ArgumentError, "Model cannot be nil or empty" if model.nil? || model.empty?
    #raise ArgumentError, "Result cannot be nil or empty" if result.nil? || result.empty?

    put_value(STR_USAGE_COMPLETION, model, text, result) # We can overwrite it, no issue.
  end

  def put_value(usage, model, input, value)
    hash = calc_hash(usage, model, input)
    value_serialized = value.to_json

    __put_value(hash, value_serialized, usage, model, input) # Call the abstract method. Yeah we put a ton of params into it, just for debugging fun!
  end

  def get_value(usage, model, input)
    hash = calc_hash(usage, model, input)
    value_serialized = __get_value(hash, usage, model, input) # Call the abstract method. Optional params are for extra potential future features.

    return nil if value_serialized.nil? || value_serialized.empty? # If the value is nil or empty, return nil

    return JSON.parse(value_serialized) # Return the deserialized value
  end

  private def __put_value(hash, value_serialized, usage = "", model = "", input = "")
    raise NotImplementedError, "Subclass must implement abstract method"
  end
  private def __get_value(hash, usage = "", model = "", input = "")
    raise NotImplementedError, "Subclass must implement abstract method"
  end

  private def calc_hash(usage, model, input)
    raise ArgumentError, "Usage cannot be nil or empty" if usage.nil? || usage.empty?
    raise ArgumentError, "Model cannot be nil or empty" if model.nil? || model.empty?
    raise ArgumentError, "Input cannot be nil or empty" if input.nil? || input.empty?

    input_trimmed = input.strip # remove whitespace, ._.

    # Security: Someone could potentially modify the input to cause weird stuff. I'm not concerned about this, but it's worth noting.
    # Just in case, the usage+model are added to the start to make it harder to do weird stuff.
    # (side-note - this is why algorithms like HMAC exist, and this matters for passwords. Also funny things like shoving arrays into a hash function)
    hash = Digest::SHA256.hexdigest("#{usage}~~~#{model}~~~#{input_trimmed}")
    return hash[0..32].upcase # Truncated to be less ugly. (16 Bytes = 32 hex chars)
  end
end
