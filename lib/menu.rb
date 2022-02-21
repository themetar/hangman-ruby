# Displays menu
def main_menu
  prompt = TTY::Prompt.new

  loop do
    command = prompt.enum_select('Main menu') do |menu|
      menu.choice 'Play Hangman', :play
      menu. choice 'Load saved game', :load if Storage.can_load?
      menu.choice 'Exit', :exit
    end

    return [command] unless command == :load
  
    # choose file
    file_path = prompt.enum_select('Choose slot') do |menu|
      Storage.savefiles.each do |filename|
        timestamp = Time.strptime(filename, '%Y%m%d%H%M%S')
        
        data = Storage.load(filename)

        menu.choice "#{GameState.secret_word(data[0], data[1]).ljust(33, ' ')}  #{timestamp.strftime('%d.%m.%Y %H:%M')}", filename
      end

      menu.choice 'Back to main menu', :back
    end

    next if file_path == :back

    return [:load, file_path]
  end
end
