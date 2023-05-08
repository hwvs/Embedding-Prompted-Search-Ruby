class SQLiteDocumentTextModel < DocumentTextModel
  require "sqlite3" #SQLite3::

  def initialize(dbPath, documentTextProvider)
    raise ArgumentError, "dbPath cannot be nil or empty" if dbPath.nil? || dbPath.empty?
    raise ArgumentError, "documentTextProvider cannot be nil" if documentTextProvider.nil?

    @dbPath = dbPath
    super(documentTextProvider)
  end

  # Handles building the class, called by the base class constructor. If the text blocks already exist, this will return early.
  #
  # @return [void]
  def build()
    # Check if there are text blocks for the identifier
    identifier = @documentTextProvider.get_identifier()
    raise "Identifier is nil" if identifier.nil? || identifier.empty?

    SQLite3::Database.open(@dbPath) do |db|
      db.execute("SELECT COUNT(*) FROM text_blocks WHERE identifier = ? LIMIT 1", identifier) do |row|
        count = row[0]
        if count > 0
          puts "Text blocks already exist for #{identifier}"
          return
        end
      end
    end

    # No blocks found, so generate them
    super
  end

  private def setup()
    create_table_if_not_exists()
  end

  # Create the table if it doesn't exist
  #
  # @return [void]
  private def create_table_if_not_exists()
    SQLite3::Database.open(@dbPath) do |db|
      db.execute("CREATE TABLE IF NOT EXISTS text_blocks (identifier TEXT, block_index INTEGER, block TEXT)")
    end
  end

  # Implement interface methods
  private def __get_text_blocks()
    identifier = @documentTextProvider.get_identifier()
    raise "Identifier is nil" if identifier.nil? || identifier.empty?

    puts "Getting blocks for #{identifier}"
    blocks = []
    SQLite3::Database.open(@dbPath) do |db|
      db.execute("SELECT block FROM text_blocks WHERE identifier = ? ORDER BY block_index ASC", identifier) do |row|
        blocks.push(row[0])
      end
    end

    puts "Done getting blocks for #{identifier}"
    return blocks
  end

  # Implement interface methods
  private def __store_text_blocks(text_blocks)
    identifier = @documentTextProvider.get_identifier()
    raise "Identifier is nil" if identifier.nil? || identifier.empty?

    puts "Storing #{text_blocks.length} blocks for #identifier='#{identifier}'"
    SQLite3::Database.open(@dbPath) do |db|
      idx = -1
      text_blocks.each do |block|
        idx += 1
        # insert new blocks, but skip existing ones
        db.execute("INSERT INTO text_blocks (identifier, block_index, block) SELECT ?, ?, ? WHERE NOT EXISTS(SELECT 1 FROM text_blocks WHERE identifier = ? AND block_index = ?)", identifier, idx, block, identifier, idx)

        if db.changes > 0 # Changed something, so it was a new block
          puts "Inserted block: #{block}"
        end
      end
    end

    puts "Done storing blocks for #{identifier}"
  end
end
