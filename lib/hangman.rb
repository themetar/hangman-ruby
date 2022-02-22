require 'bundler/setup'
require_relative 'gamestate'
require 'tty-prompt'
require 'time'

require_relative './menu'
require_relative './storage'

# replay loop
loop do
  # show menu and get choice
  command, opt_filepath = main_menu

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
    data = [word, game.guesses.join]
    
    Storage.save(data)
  end

  # delete old savefile if there was one
  Storage.delete(opt_filepath) if command == :load
end
