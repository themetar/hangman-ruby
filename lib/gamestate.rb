require 'pastel'

# Holds and manages game state for a single round
class GameState
  # Limit of wrong guesses
  MAX_MISTAKES = 5

  # format secret
  def self.secret_word(word, guesses)
    word.gsub(/./) { |char| guesses.include?(char) ? char : '_' } .split('').join(' ')
  end

  attr_accessor :guesses

  def initialize(word)
    @word = word
    @guesses = []
    @mistakes = 0
    @hits = 0
  end

  # Updates state wth new guess
  # guess can be a single character or a string
  def add_guess(guess)
    guess.each_char do |char|
      unless @guesses.include?(char)
        @guesses << char
  
        @mistakes += 1 unless @word.include?(char)
        @hits +=  @word.count(char)
      end
    end
  end

  def game_over?
    @mistakes > MAX_MISTAKES || game_won?
  end

  def game_won?
    @hits == @word.length
  end

  # Prints status to standard output
  def ui_print
    # O
    #/|\
    #/ \    _ _ a _ _ _ _     E, R

    pastel = Pastel.new

    # prepare
    head  = " #{@mistakes > MAX_MISTAKES ? pastel.red('O') : 'O'} "
    torso = '/|\\'.each_char.each_with_index.collect { |c, i| @mistakes - 2 > i ? pastel.red(c) : c } .join
    legs  = "#{@mistakes > 0 ? pastel.red('/') : '/' } #{@mistakes > 1 ? pastel.red('\\') : '\\'}"

    correct, incorrect = @guesses.partition { |char| @word.include?(char) }
    
    secret = self.class.secret_word(@word, correct)
    wrongs = pastel.red(incorrect.collect(&:upcase).join(', '))
    
    # print
    puts head 
    puts torso
    puts "#{legs}     #{secret}     #{wrongs}"
  end

  # Runs the game loop. Asking the player for guesses, updating its state.
  # Returns game's outcome
  def run
    prompt = TTY::Prompt.new

    # game loop
    until game_over?
      ui_print
      
      guess = prompt.ask 'Enter guess, or command:', default: '?' do |q|
                q.validate /\A([a-zA-Z]+|#|\?)\Z/, "Must either be string of letters or a single command symbol: #, ?"
                q.modify :trim, :down
              end

      return :save if guess == '#'  # quit game

      if guess == '?'
        puts Help::OBJECTIVE, "\n"
        puts Help::INPUT
        prompt.keypress('Press any key to continue...')
        next  # go back to start of loop
      end

      add_guess(guess)
    end

    # last printout
    ui_print

    if game_won?
      puts "Correct!"
    else
      puts "You lost. The word was: #{@word.split('').join(' ')}"
    end

    game_won? ? :won : :lost  # return status
  end
end
