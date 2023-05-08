require "openai"

class OpenAIProvider
  DEFAULT_MODEL_EMBEDDINGS = "text-embedding-ada-002"
  DEFAULT_MODEL_COMPLETIONS = "text-davinci-003"

  # Embeddings text-search

  # @param [OpenAICacheProvider] openAICacheProvider
  # @param [String] api_key
  def initialize(openAICacheProvider, api_key = nil)
    raise ArgumentError, "Error, openAICacheProvider is null (I'm not a billionaire!!! Cache those calls!)" if openAICacheProvider.nil?
    @openAICacheProvider = openAICacheProvider

    @api_key = api_key.nil? ? ENV["OPENAI_API_KEY"] : api_key
    raise ArgumentError, "Either the OPENAI_API_KEY environment variable must be set, or an api_key must be passed in" if @api_key.nil?

    @openai = OpenAI::Client.new(access_token: @api_key)
  end

  def get_default_model_embeddings
    return DEFAULT_MODEL_EMBEDDINGS
  end

  def get_default_model_completions
    return DEFAULT_MODEL_COMPLETIONS
  end

  # Embeddings text-search for the given text. Results are cached in the OpenAICacheProvider.
  #
  # @param [String] text
  # @param [String] model = nil
  # @param [Boolean] bypass_cache = false
  # @return [Array<Float>]
  def get_embeddings_for_text(text, model = nil) #, bypass_cache = false
    model = DEFAULT_MODEL_EMBEDDINGS if model.nil?

    # Try to get from cache

    ### Actually, bypass_cache makes no sense. Embeddings can never change, so we should always cache them. ._.
    #if !bypass_cache
    cached_result = @openAICacheProvider.get_embeddings_for_text(text, model)
    if !cached_result.nil?
      return cached_result
    end
    #end

    # Try - Catch
    begin
      puts "+++++ Calling OpenAI API +++++"
      puts "Text: " + text
      puts "Model: " + model
      puts "+++++++++++++++++++++++++++++"

      response = @openai.embeddings(
        parameters: {
          model: model,
          input: text,
        },
      )

      #puts "Response - Inspect: " + response.inspect

      embedding = response["data"][0]["embedding"]

      if embedding.nil? || embedding.empty?
        raise "Error, embedding is nil or empty"
      end

      # Cache the result
      @openAICacheProvider.set_embeddings_for_text(text, model, embedding)

      return embedding
    rescue => exception
      puts "--- Error in get_embeddings_for_text ---"
      puts "Error: " + exception.message
      puts "Backtrace: " + exception.backtrace.inspect
      return nil
    end
  end

  # Completions text-generation (GPT-3)
  #
  # @param [String] text
  # @param [String] model = nil
  # @param [String] stop = nil
  # @param [Boolean] bypass_cache = false
  # @param [Integer] max_tokens
  # @param [Float] temperature
  # @param [Float] top_p
  # @param [Float] frequency_penalty
  # @param [Float] presence_penalty
  # @return [String]
  def get_completion_for_text(text, model = nil, stop = nil, bypass_cache = false, max_tokens = 512, temperature = 0.7, top_p = 1, frequency_penalty = 0, presence_penalty = 0.0)
    model = DEFAULT_MODEL_COMPLETIONS if model.nil?

    if !bypass_cache
      cached_result = @openAICacheProvider.get_completion_for_text(text, model)
      if !cached_result.nil?
        return cached_result
      end
    end

    # Try - Catch
    begin
      puts "+++++ Calling OpenAI API +++++"
      puts "Text: " + text
      puts "Model: " + model
      puts "+++++++++++++++++++++++++++++"

      response = @openai.completions(
        parameters: {
          model: model,
          prompt: text,
          stop: stop,
          max_tokens: max_tokens,
          temperature: temperature,
          top_p: top_p,
          frequency_penalty: frequency_penalty,
          presence_penalty: presence_penalty,
        },
      )

      #puts "Response - Inspect: " + response.inspect

      completion = response["choices"][0]["text"]

      if completion.nil? # || completion.empty?
        return "" # nil is bad, empty is ok (stop condition)
      end

      # Cache the result
      @openAICacheProvider.set_completion_for_text(text, model, completion)

      return completion
    rescue => exception
      puts "--- Error in get_completion_for_text ---"
      puts "Error: " + exception.message
      puts "Backtrace: " + exception.backtrace.inspect
      return nil
    end
  end
end
