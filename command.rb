$LOAD_PATH << './'
require './queue'

module EventReporter
  class Command
    ALL_COMMANDS = {"load" => "loads a new file",
            "help" => "shows a list of available commands",
            "queue" => "a set of data",
            "queue count" => "total items in the queue",
            "queue clear" => "empties the queue",
            "queue print" => "prints the queue",
            "queue print by" => "sorts the queue by attribute",
            "queue save to" => "exports queue to a CSV",
            "find" => "load the queue with matching records"}
    CSV_OPTIONS = {:headers => true, :header_converters => :symbol}

    attr_accessor :attendees

    def initialize
      @my_queue = Queue.new
    end

    # validates a command
    def valid? (command)
      ALL_COMMANDS.keys.include?(command)
    end

    def execute(command, args)
      if (valid? command)
        self.send(command,args)
      else
        error_message(args)
      end
    end

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

    def find_implemtation(data, args)
      if valid_args_for_find?(args)
        temp_queue = data.select do |r|
          r.send(args[0]).upcase == args[1].upcase
        end
      else
        error_message(args)
      end
    end

    def find(args)
      args = parse_find_arguments(args)
      temp_queue = @attendees
      args.each_with_index do |f, index| 
        if index % 2 == 0
          puts "finding #{args}"
          temp_queue = find_implemtation(temp_queue, args.slice(index, 2))
        end
      end
      @my_queue.load(temp_queue)
      find_result_message(@my_queue.count, args)
    end

    def find_result_message(count, args)
      if count == 0
       "I couldn't find #{args[1]} in #{args[0]}."
      else
        puts "I found #{count} items."
      @my_queue.print
      end
    end

    def parse_find_arguments(args)
      result_args = args[0..1]
      args.each_with_index do |f, index|
        if f == "and"
          result_args += args[index+1..index+2]
        end
      end
      result_args
    end

    def find_result_message(count, args)
      if count == 0
        "I couldn't find #{args[1]} in #{args[0]}."
      else
        puts "I found #{count} items."
        @my_queue.print
      end
    end

    def valid_args_for_find?(args)
      args.count == 2 && Attendee.method_defined?(args[0])
    end

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

    def valid_args_for_help?(args)
      args.empty? || ALL_COMMANDS.has_key?(args)
    end

    def valid_parameters_for_load?(parameters)
      parameters.count == 1 && parameters[0] =~ /\.csv$/
    end

    def load(filename = ["event_attendees.csv"])
      if valid_parameters_for_load?(filename)
        filename = filename.join("")

        if (File.exists?(filename))
          file = CSV.open(filename, CSV_OPTIONS)
          @attendees = file.collect { |line| EventReporter::Attendee.new(line) }
          @my_queue.load(@attendees)
          "File successfully loaded."
        else
          error_message(filename)
        end
      end
    end

    def error_message(error)
      "Sorry, I didn't understand #{error.join(" ")}"
    end


  end
end