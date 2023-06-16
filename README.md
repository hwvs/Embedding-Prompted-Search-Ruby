# Embedding-Prompted-Search-Ruby
![workflow badge](https://github.com/hwvs/Embedding-Prompted-Search-Ruby/actions/workflows/ruby.yml/badge.svg)

Ruby library for searching documents/books using OpenAI API (GPT) to find related embeddings, enabling LLM-based tasks such as answering questions about authors or their books with context provided by the related embeddings.

# Todo
- Create a "factory" or "builder" class to do all of the heavy-lifting
- ~Auto-detect which provider to use for a document based off of MIME/extension?~ (done)
- Clean up the class names which might not meet Ruby standards
- **Create more Tests!**

# Usage
```ruby
# TODO: Create a Factory to create everything needed

# 1. Obtain the provider for a specific filetype
document_text_provider = DocumentTextProvider.get_provider_for_file(@filename)

# 2. Instantiate a new document model
sqlite_document_text_model = SQLiteDocumentTextModel.new(DATABASE_PATH, document_text_provider)

# 2.1 Generate the database
sqlite_document_text_model.build()

# 3. Instantiate a new OpenAI provider with a cache provider
@open_ai_cache_provider = SQLiteOpenAICacheProvider.new(DATABASE_PATH)
@open_ai_provider = OpenAIProvider.new(@open_ai_cache_provider)

# 4. Instantiate a new document embeddings model
@document_embeddings_model = SQLiteDocumentEmbeddingsModel.new(DATABASE_PATH, sqlite_document_text_model, @open_ai_provider)

# 5. Instantiate a new document search model
@document_search_model = DocumentSearchModel.new(@document_embeddings_model)
```
