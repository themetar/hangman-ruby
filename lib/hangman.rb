require 'bundler/setup'
require_relative 'gamestate'
require 'tty-prompt'
require 'time'

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
  can_load = Dir.exist?(saves_path) && Dir.new(saves_path).each.any? { |filename| File.file?(File.join(saves_path, filename)) }

  command = prompt.enum_select('Main menu') do |menu|
              menu.choice 'Play Hangman', :play
              menu. choice 'Load saved game', :load if can_load
              menu.choice 'Exit', :exit
            end

  if command == :load
    # choose file
    file_path = prompt.enum_select('Choose file') do |menu|
      Dir.new(saves_path).each do |filename|
        next if filename == '.'
        next if filename == '..'

        timestamp = Time.strptime(filename, '%Y%m%d%H%M%S')
        
        data = File.open(File.join(saves_path, filename), 'rb') { |save_f| Marshal.load(save_f) }
        menu.choice "#{GameState.secret_word(data[0], data[1]).ljust(33, ' ')}  #{timestamp.strftime('%d.%m.%Y %H:%M')}", filename
      end
      menu.choice 'Back to main menu', :back
    end

    next if file_path == :back

    save_f = File.open(File.join(saves_path, file_path), 'rb')
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

      filename = "#{Time.new.strftime('%Y%m%d%H%M%S')}"

      File.open(File.join(saves_path, filename), 'wb') do |file|
        Marshal.dump(data, file)
      end
    end
  when :exit
    break
  end
end
