require_relative 'gamestate'

# load word set
lexicon = []

words_filepath = File.join(File.dirname(__FILE__), '_data', 'google-10000-english-no-swears.txt')

File.open(words_filepath, 'r') do |file|
  until file.eof?
    word = file.readline.strip
    lexicon << word if word.length.between?(5, 12)
  end
end

# choose word
word = lexicon[rand(lexicon.length)]

# initialize game state
game = GameState.new(word)

until game.game_over?
  game.ui_print

  print 'Enter guess: '
  
  guess = gets.strip

  game.add_guess(guess)

  if game.game_won?
    puts "Correct!"
    game.ui_print
    break
  end
end

unless game.game_won?
  puts "You lost. The word was:"
  puts word.split('').join(' ')
end
