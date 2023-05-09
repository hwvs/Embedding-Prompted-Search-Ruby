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

# 1. Get the provider for a specific filetype
documentTextProvider = DocumentTextProvider.get_provider_for_file(@filename)

# 2. Create a new document model
sqliteDocumentTextModel = SQLiteDocumentTextModel.new(DATABASE_PATH, documentTextProvider)
# 2.1 generate the database
sqliteDocumentTextModel.build()

# 3. Create a new OpenAI provider with a cache provider
@openAICacheProvider = SQLiteOpenAICacheProvider.new(DATABASE_PATH)
@openAIProvider = OpenAIProvider.new(@openAICacheProvider)

# 4. Create a new document embeddings model
@documentEmbeddingsModel = SQLiteDocumentEmbeddingsModel.new(DATABASE_PATH, sqliteDocumentTextModel, @openAIProvider)

# 5. Create a new document search model
@documentSearchModel = DocumentSearchModel.new(@documentEmbeddingsModel)
```
