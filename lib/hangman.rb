require 'bundler/setup'
require_relative 'gamestate'
require 'tty-prompt'

prompt = TTY::Prompt.new

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

# main menu
loop do
  can_load = File.exist?(File.join(saves_path, 'savefile.dat'))

  command = prompt.enum_select('Main menu') do |menu|
              menu.choice 'Play Hangman', :play
              menu. choice 'Load saved game', :load if can_load
              menu.choice 'Exit', :exit
            end

  if command == :load
    save_f = File.open(File.join(saves_path, 'savefile.dat'), 'rb')
    data = Marshal.load(save_f)
    save_f.close

    word, guesses = data
    game = GameState.new(word)
    game.add_guess(guesses)

    command = :play # hack
  else
    # choose word
    word = lexicon[rand(lexicon.length)]

    # initialize game state
    game = GameState.new(word)
  end

  case command
  when :play
    # run it
    outcome = game.run

    # save game
    if outcome == :save
      Dir.mkdir(saves_path) unless Dir.exist?(saves_path)

      data = [word, game.guesses.join] 

      File.open(File.join(saves_path, 'savefile.dat'), 'wb') do |file|
        Marshal.dump(data, file)
      end
    end
  when :exit
    break
  end
end
