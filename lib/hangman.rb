require 'bundler/setup'
require_relative 'gamestate'
require 'tty-prompt'
require 'time'

require_relative './menu'
require_relative './storage'

# replay loop
loop do
  # show menu and get choice
  command, opt_filepath = main_menu(Storage::SAVES_PATH)

  break if command == :exit

  if command == :load
    # load saved data
    data = Storage.load(opt_filepath)

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
    Dir.mkdir(Storage::SAVES_PATH) unless Dir.exist?(Storage::SAVES_PATH)

    data = [word, game.guesses.join] 

    filename = "#{Time.new.strftime('%Y%m%d%H%M%S')}"

    File.open(File.join(Storage::SAVES_PATH, filename), 'wb') do |file|
      Marshal.dump(data, file)
    end
  end
end
