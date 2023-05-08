class DocumentSearchModel
  def initialize(documentEmbeddingsModel)
    raise "documentEmbeddingsModel is nil" if documentEmbeddingsModel.nil?

    @documentEmbeddingsModel = documentEmbeddingsModel
  end

  # Finds the best text block(s) based on the distance of the embeddings of the text block(s) and the search text.
  #
  # @param to_search [String] The text used to query for the best text block(s)
  # @max_elements [Integer] The maximum number of elements to return
  # @return [Array<Hash>, nil] An array of hashes containing the 'distance' and 'block' of the best text block(s),
  #   or nil if no suitable text block is found. The array can have 0-1000 elements.
  #   Example structure of the returned array:
  #   [
  #     {'distance' => 0.00013, 'block' => 'This is text.'},
  #     {'distance' => 0.00013, 'block' => 'This is text.'}
  #   ]
  def SearchTextBlocks(to_search, max_elements = -1)
    raise "to_search cannot be nil" if to_search.nil?
    raise "to_search cannot be empty" if to_search.empty?

    to_search = to_search.strip # Maybe it'll be empty, but that's fine
    puts "[Debug]  Searching for '#{to_search}'"

    # Get the embeddings for the search text
    search_embeddings = @documentEmbeddingsModel.get_embeddings_for_text(to_search)

    return SearchTextBlockByEmbeddings(search_embeddings, max_elements)
  end

  # Finds the best text block(s) based on the distance of the embeddings of the text block(s) and the search-embedding.
  #
  # @param to_search [String] The text used to query for the best text block(s)
  # @max_elements [Integer] The maximum number of elements to return
  # @return [Array<Hash>, nil] An array of hashes containing the 'distance' and 'block' of the best text block(s),
  #   or nil if no suitable text block is found. The array can have 0-1000 elements.
  #   Example structure of the returned array:
  #   [
  #     {'distance' => 0.00013, 'block' => 'This is text.'},
  #     {'distance' => 0.00013, 'block' => 'This is text.'}
  #   ]
  def SearchTextBlockByEmbeddings(search_embeddings, max_elements = -1)
    raise "search_embeddings is nil" if search_embeddings.nil?
    raise "search_embeddings is empty" if search_embeddings.empty?

    # Get the embeddings for the document
    document_embeddings = @documentEmbeddingsModel.get_all_embeddings()

    # ######################## OLD SOLUTION ########################
    # Find the best match (only one, and not in an array format)
    #best_match = nil
    #best_match_score = -1
    #document_embeddings.each do |embedding_container|
    #embedding = embedding_container.embedding
    #score = get_similarity(embedding, search_embeddings)
    #if score > best_match_score
    #  best_match_score = score
    #  best_match = embedding_container.text
    #end
    #end
    #puts "Best match: '#{best_match}'"
    #puts "Distance:   #{best_match_score}"
    #return best_match
    # ####################################N#########################

    # ######################## NEW SOLUTION ########################

    # Add every single match to an array (as relational array), and then sort the array before returning it
    matches = []
    document_embeddings.each do |embedding_container|
      embedding = embedding_container.embedding
      score = get_similarity(embedding, search_embeddings)
      matches.push({ "distance" => score, "block" => embedding_container.text })
    end

    # Sort the array, by cosine similarity. Best matches first (1-minus)
    matches.sort_by! { |match| 1 - match["distance"] }

    # Limit the array to the max_elements
    if max_elements > 0
      matches = matches[0..max_elements - 1]
    end

    # Return the array
    return matches
  end

  # Calculates the cosine similarity between two arrays.
  #
  # @param arr_a [Array] The first array
  # @param arr_b [Array] The second array
  # @return [Float] The cosine similarity between the two arrays
  private def get_similarity(arr_a, arr_b)
    raise "arr_a is nil" if arr_a.nil?
    raise "arr_b is nil" if arr_b.nil?
    raise "arr_a is not an array" if !arr_a.is_a?(Array)
    raise "arr_b is not an array" if !arr_b.is_a?(Array)

    # Cosine similiarity - single line
    return (arr_a.zip(arr_b).map { |a, b| a * b }.reduce(:+) / (Math.sqrt(arr_a.map { |a| a ** 2 }.reduce(:+)) * Math.sqrt(arr_b.map { |b| b ** 2 }.reduce(:+)))).round(2)
  end
end
