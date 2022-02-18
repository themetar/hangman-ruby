require 'bundler/setup'
require_relative 'gamestate'
require 'tty-prompt'
require 'time'

require_relative './menu'

# load word set
lexicon = []

datadir_path = File.join(File.dirname(__FILE__), '_data')
words_filepath = File.join(datadir_path, 'google-10000-english-no-swears.txt')

File.open(words_filepath, 'r') do |file|
  until file.eof?
    word = file.readline.strip
    lexicon << word if word.length.between?(5, 12)
  end
end

saves_path = File.join(datadir_path, 'saves')

# replay loop
loop do
  # show menu and get choice
  command, opt_filepath = main_menu(saves_path)

  break if command == :exit

  if command == :load
    # load saved data
    data = File.open(File.join(saves_path, opt_filepath), 'rb') { |file| Marshal.load(file) }

    word, guesses = data

    # setup game
    game = GameState.new(word)
    game.add_guess(guesses)
  else
    # choose word
    word = lexicon[rand(lexicon.length)]

    # initialize game state
    game = GameState.new(word)
  end

  # run it
  outcome = game.run

  # save game
  if outcome == :save
    Dir.mkdir(saves_path) unless Dir.exist?(saves_path)

    data = [word, game.guesses.join] 

    filename = "#{Time.new.strftime('%Y%m%d%H%M%S')}"

    File.open(File.join(saves_path, filename), 'wb') do |file|
      Marshal.dump(data, file)
    end
  end
end
