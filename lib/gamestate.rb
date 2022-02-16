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
    puts "#{@mistakes} / #{MAX_MISTAKES}"

    correct, incorrect = @guesses.partition { |char| @word.include?(char) }
    puts @word.gsub(/./) { |char| correct.include?(char) ? char : '_' } .split('').join(' ') + "\t" + incorrect.join(', ')
  end
end
