require 'bundler/setup'
require_relative 'gamestate'
require 'tty-prompt'

prompt = TTY::Prompt.new

# load word set
lexicon = []

words_filepath = File.join(File.dirname(__FILE__), '_data', 'google-10000-english-no-swears.txt')

File.open(words_filepath, 'r') do |file|
  until file.eof?
    word = file.readline.strip
    lexicon << word if word.length.between?(5, 12)
  end
end

# main menu
loop do
  command = prompt.enum_select('Main menu') do |menu|
              menu.choice 'Play Hangman', :play
              menu.choice 'Exit', :exit
            end

  case command
  when :play
    # choose word
    word = lexicon[rand(lexicon.length)]

    # initialize game state
    game = GameState.new(word)
    # and run it
    game.run
  when :exit
    break
  end
end
