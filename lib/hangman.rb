require 'bundler/setup'
require_relative 'gamestate'
require 'tty-prompt'
require 'time'

require_relative './menu'
require_relative './storage'

saves_path = File.join(Storage::DATA_DIR_PATH, 'saves')

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
    # randomly choose word
    word = Storage.lexicon.sample

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
