$LOAD_PATH << './'
require './command'
require './attendee'
require 'csv'


module EventReporter
  class Reporter
    EXIT_COMMANDS = ["quit", "q", "e", "exit"]

    def initialize
      @controller = EventReporter::Command.new
      @controller.load
      run
    end

    def parse_user_input(input)
      [ input.first.downcase, input[1..-1]]
    end

    def prompt_user
      printf "enter command > "
      gets.strip.split
    end

    # Controls the main program loop
    def run
      puts "Welcome to the Event Reporter"
      results = ""

      while results
        results = execute_command(prompt_user)
        puts results if results
      end
      puts "Goodbye!"
    end

    def execute_command(input)
      if input.any?
        command, args = parse_user_input(input)
        result = @controller.execute(command, args) unless quitting?(command)
      else
        result = "You didn't type anything. Please try again."
      end
    end

    def quitting?(command)
      EXIT_COMMANDS.include?(command)
    end

  end
end

@reporter = EventReporter::Reporter.new
