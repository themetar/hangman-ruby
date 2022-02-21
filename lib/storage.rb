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

  # Store data
  def self.save(data)
    Dir.mkdir(SAVES_PATH) unless Dir.exist?(SAVES_PATH)

    filename = "#{Time.new.strftime('%Y%m%d%H%M%S')}"

    File.open(File.join(SAVES_PATH, filename), 'wb') { |file| Marshal.dump(data, file) }
  end

  # Loads saved data
  def self.load(file_name)
    File.open(File.join(SAVES_PATH, file_name), 'rb') { |file| Marshal.load(file) }
  end

  # Test if there are saved files
  def self.can_load?
    Dir.exist?(SAVES_PATH) && Dir.each_child(SAVES_PATH).any? { |filename| File.file?(File.join(SAVES_PATH, filename)) }
  end
end
