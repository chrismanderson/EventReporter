$LOAD_PATH << './'
require './queue'
require './attendee'

module EventReporter
  class Command
    ALL_COMMANDS = {"load" => "loads a new file",
            "help" => "shows a list of available commands",
            "add" => "add a query to the current queue",
            "subtract" => "removes a query to the current queue",
            "queue" => "a set of data",
            "queue count" => "total items in the queue",
            "queue clear" => "empties the queue",
            "queue print" => "prints the queue",
            "queue print by" => "sorts the queue by attribute",
            "queue save to" => "exports queue to a CSV",
            "find" => "load the queue with matching records"}
    CSV_OPTIONS = {:headers => true, :header_converters => :symbol}
    DEFAULT_FILE = "event_attendees.csv"

    attr_accessor :attendees

    # init method and generates a new queue
    def initialize
      @my_queue = Queue.new
    end

    # validates a command
    def valid? (command)
      ALL_COMMANDS.keys.include?(command)
    end

    # main method to execute commands
    # sends parsed command to relevant method
    def execute(command, args)
      if (valid? command)
        self.send(command,args)
      else
        error_message(args)
      end
    end

    # method to handle queue commands
    # calls the queue instance to organize the data
    def queue(args)
      puts "args are #{args[0..1].join(" ")}"
      if valid_args_for_queue?(args)
        "You called queue with valid #{args}"
        case args.first
          when "count" ; @my_queue.count
          when "print" ; @my_queue.print(args.last)
          when "clear" ; @my_queue.clear
          when "save"; @my_queue.save_to(args.last)
        end
      else
        error_message(args)
      end
    end

    # validates queue arguments
    def valid_args_for_queue?(args)
      if !%w(count clear print save).include?(args[0])
        false
      elsif args[0] == "print"
        args.count == 1 || (args[1] == "by" && args.count == 3 )
      elsif args[0] == "save"
        args[1] == "to" && args.count == 3 
      else
        true
      end
    end

    # main method that governs finding
    # parses the data and sends data and parsed args
    # to find_implementation which actually implements finding
    def find(args, data = @attendees)
      if valid_args_for_find?(args)
        args = parse_find_arguments(args)
        args.each_with_index do |f, i|
          if i % 2 == 0
            puts "finding #{args}"
            data = find_implemtation(data, args.slice(i, 2))
          end
        end
        @my_queue.load(data)
        find_result_message(@my_queue.count, args)
      else
         error_message(args)
      end
    end

    # implements the algorithm for finding data
    def find_implemtation(data, args)
      if valid_args_for_find?(args)
        temp_queue = data.select do |r|
          r.send(args[0]).upcase == args[1].upcase
        end
        temp_queue
      else
        error_message(args)
      end
    end

    # validates find arguments
    # accounting for 'ands'
    def valid_args_for_find?(args)
      args.each_with_index do |a, i|
        if i % 3 == 0
          return false unless Attendee.method_defined?(a) && !args[i + 1].nil?
        end
      end
      true
    end

    # parses the arguments to the find command
    # allowing for multiple uses of the 'and' operator
    def parse_find_arguments(args)
      result_args = args[0..1]
      args.each_with_index do |f, i|
        if f == "and"
          result_args += args[i+1..i+2]
        end
      end
      result_args
    end

    # displays the result of a search
    def find_result_message(count, args)
      if count == 0
        "I couldn't find #{args[1]} in #{args[0]}."
      else
        puts "I found #{count} items."
        @my_queue.print
      end
    end

    # subtracts a search from the current queue
    def subtract(args)
      new_query = []
      if valid_args_for_addsub?(args)
        args = parse_args_for_addsub(args)
        new_query = find_implemtation(@attendees, args)
        new_query = @my_queue.current_queue - new_query
        @my_queue.load(new_query)
        @my_queue.print
      else
        error_message(args)
      end
    end

    # adds a search to the current queue
    def add(args)
      new_query = []
      if valid_args_for_addsub?(args)
        args = parse_args_for_addsub(args)
        new_query = find_implemtation(@attendees, args)
        new_query = @my_queue.current_queue + new_query
        @my_queue.load(new_query)
        @my_queue.print
      else
        error_message(args)
      end
    end

    # validates args for the add/subtract methods
    def valid_args_for_addsub?(args)
      args.first == "find" && valid_args_for_find?(args[1..-1])
    end

    # parses the args for add_sub
    def parse_args_for_addsub(args)
      args[1..-1]
    end

    # help method, grabs data from the constant ALL_COMMANDS
    def help(args)
      args = args.join(" ")
      if (valid_args_for_help?(args))
        if (ALL_COMMANDS.has_key?(args))
          ALL_COMMANDS[args]
        else
          ALL_COMMANDS.keys
        end
      else
        error_message(args)
      end
    end

    # validates arguments for the help method
    def valid_args_for_help?(args)
      args.empty? || ALL_COMMANDS.has_key?(args)
    end

    # validates arguments for load, checking for a csv file
    def valid_parameters_for_file?(parameters)
      !parameters.nil? && parameters =~ /\.csv$/
    end

    # loads a file, passing in a default if there is no file specified
    def load(filename = DEFAULT_FILE)
      # protects against 'load' with no argument
      if filename.empty? then filename = DEFAULT_FILE end
      if valid_parameters_for_file?(filename)
        if (File.exists?(filename))
          file = CSV.open(filename, CSV_OPTIONS)
          @attendees = file.collect{ |line| EventReporter::Attendee.new(line) }
          @my_queue.load(@attendees)
          "File successfully loaded."
        else
          error_message(filename)
        end
      else
        error_message(filename)
      end
    end

    # error message method for all other methods
    def error_message(error)
      "Sorry, I didn't understand #{error.join(" ")}"
    end
  end
end