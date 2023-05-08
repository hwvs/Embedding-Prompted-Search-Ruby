class SQLiteOpenAICacheProvider < OpenAICacheProvider
  require "sqlite3" #SQLite3::

  def initialize(dbPath)
    raise ArgumentError, "dbPath cannot be nil or empty" if dbPath.nil? || dbPath.empty?

    @dbPath = dbPath

    create_table_if_not_exists()
  end

  private def create_table_if_not_exists
    SQLite3::Database.open(@dbPath) do |db|
      db.execute("CREATE TABLE IF NOT EXISTS cache_openai (hash TEXT PRIMARY KEY, value TEXT, input TEXT, usage TEXT, model TEXT)")
    end
  end

  private def __put_value(hash, value_serialized, usage = "", model = "", input = "")
    # upsert
    SQLite3::Database.open(@dbPath) do |db|
      db.execute("INSERT OR REPLACE INTO cache_openai (hash, value, input, usage, model) VALUES (?, ?, ?, ?, ?)", [hash, value_serialized, input, usage, model])
    end

    return true
  end

  private def __get_value(hash, usage = "", model = "", input = "")
    SQLite3::Database.open(@dbPath) do |db|
      db.execute("SELECT value FROM cache_openai WHERE hash = ?", [hash]) do |row|
        return row[0] # Return the value
      end
    end

    return nil # If we didn't find anything, return nil
  end
end
