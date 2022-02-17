require 'pastel'

# Holds and manages game state for a single round
class GameState
  # Limit of wrong guesses
  MAX_MISTAKES = 5

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
    
    secret = @word.gsub(/./) { |char| correct.include?(char) ? char : '_' } .split('').join(' ')
    wrongs = pastel.red(incorrect.collect(&:upcase).join(', '))
    
    # print
    puts head 
    puts torso
    puts "#{legs}     #{secret}     #{wrongs}"
  end

  def run
    prompt = TTY::Prompt.new

    until game_over?
      ui_print
      
      guess = prompt.ask 'Enter guess, or # to save and exit:' do |q|
                q.validate /\A([a-zA-Z]+|#)\Z/, "Must either be string of letters, one or more; or a single command symbol: #"
                q.modify :trim, :down
              end

      return :save if guess == '#'  # quit game

      add_guess(guess)

      if game_won?
        puts "Correct!"
        ui_print
        break
      end 
    end

    unless game_won?
      puts "You lost. The word was:"
      puts @word.split('').join(' ')
    end

    game_won? ? :won : :lost  # return status
  end
end
