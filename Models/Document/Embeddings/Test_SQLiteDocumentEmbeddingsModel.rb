class Test_SQLiteDocumentEmbeddingsModel < ActiveSupport::TestCase
  require_relative File.join("..", "..", "..", "test_helper.rb")
  require "sqlite3" #SQLite3::

  def test_table_is_created()
    assert $test_documentEmbeddingsModel != nil, "$test_documentEmbeddingsModel is nil"

    # The table should exist if the constructor has been run
    #      db.execute("CREATE TABLE IF NOT EXISTS embeddings (identifier TEXT, block_index INTEGER, block_text TEXT, embedding_container_json TEXT)")

    SQLite3::Database.open(DATABASE_PATH) do |db|
      # Get col names
      colNames = db.execute("PRAGMA table_info(embeddings)").map { |row| row[1] }
      assert(colNames.include?("identifier"), "Table does not have identifier column")
      assert(colNames.include?("block_index"), "Table does not have block_index column")
      assert(colNames.include?("block_text"), "Table does not have block_text column")
      assert(colNames.include?("embedding_container_json"), "Table does not have embedding_container_json column")
    end
  end

  def test_build()
    assert $test_documentEmbeddingsModel != nil, "$test_documentEmbeddingsModel is nil"
    assert $test_documentTextProvider != nil, "$test_documentTextProvider is nil"

    # Delete all rows
    SQLite3::Database.open(DATABASE_PATH) do |db|
      db.execute("DELETE FROM embeddings")
    end

    # Check that there are no rows
    SQLite3::Database.open(DATABASE_PATH) do |db|
      db.execute("SELECT COUNT(*) FROM embeddings") do |row|
        assert(row[0] == 0, "There are rows in the embeddings table ('DELETE FROM embeddings' failed)")
      end
    end

    # Build the text-model (required for the embeddings-model)
    $test_sqliteDocumentTextModel.build()

    # Build the model
    $test_documentEmbeddingsModel.initialize_embeddings()

    # Check that there are rows
    SQLite3::Database.open(DATABASE_PATH) do |db|
      db.execute("SELECT COUNT(*) FROM embeddings") do |row|
        assert(row[0] > 0, "There are no rows in the embeddings table ('initialize_embeddings' failed)")
      end
    end

    # Get one row
    SQLite3::Database.open(DATABASE_PATH) do |db|
      db.execute("SELECT * FROM embeddings ORDER BY block_index LIMIT 1") do |row|
        assert(row[0] == $test_documentTextProvider.get_identifier(), "Identifier does not match")
        assert(row[1] == 0, "Block index of first block is not 0")
        assert(row[2].nil? == false, "Text block is nil")
      end
    end
  end
end
