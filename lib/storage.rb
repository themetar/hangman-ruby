module Storage
  DATA_DIR_PATH = File.join(File.dirname(__FILE__), '_data')

  SAVES_PATH = File.join(Storage::DATA_DIR_PATH, 'saves')

  # List of eligible words
  def self.lexicon
    # create class var lexicon if not already set
    @@lexicon ||= File.open(File.join(DATA_DIR_PATH, 'google-10000-english-no-swears.txt'), 'r') do |file|
      lexicon = []

      until file.eof?
        word = file.readline.strip
        lexicon << word if word.length.between?(5, 12)
      end

      lexicon
    end

    @@lexicon
  end

  # Loads saved data
  def self.load(file_name)
    File.open(File.join(SAVES_PATH, file_name), 'rb') { |file| Marshal.load(file) }
  end
end
