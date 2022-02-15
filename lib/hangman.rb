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

# mistake counter
mistakes = 0

MAX_MISTAKES = 5

guesses = []

hits = 0

def print_word_and_guesses(word, guesses)
  correct, incorrect = guesses.partition { |char| word.include?(char) }
  puts word.gsub(/./) { |char| correct.include?(char) ? char : '_' } .split('').join(' ') + "\t" + incorrect.join(', ')
end

while mistakes < MAX_MISTAKES
  puts "#{mistakes} / #{MAX_MISTAKES}"

  print_word_and_guesses(word, guesses)

  print 'Enter guess: '
  
  guess = gets.strip

  guess.each_char do |char|
    unless guesses.include?(char)
      guesses << char

      mistakes += 1 unless word.include?(char)
      hits +=  word.count(char)
    end
  end

  if hits == word.length
    puts "Correct!"
    print_word_and_guesses(word, guesses)
    break
  end
end

if mistakes == MAX_MISTAKES
  puts "You lost. The word was:"
  puts word.split('').join(' ')
end
