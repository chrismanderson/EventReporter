require './attendee'

module EventReporter
  class Queue
    OUTPUT_HEADERS = ['LAST NAME', 'FIRST NAME', 'EMAIL',
            'ZIPCODE', 'CITY', 'STATE', 'ADDRESS', 'PHONE']
    DEFAULT_SORT_KEY = "reg_date"

    attr_accessor :current_queue

    # prints the tab deliminated list
    # sorts by reg_date by default, otherwise takes an argument to sort
    def print(parameters)
      if parameters == "print" then parameters = DEFAULT_SORT_KEY end
      result = "#{OUTPUT_HEADERS.join("\t")}\n"
      if validate_print_attributes?(parameters)
        temp_queue = @current_queue.sort_by { |hsh| hsh.send(parameters) }
        temp_queue.each do |a|
          result += "#{a.last_name}\t#{a.first_name}\t#{a.email}\t"
          result += "#{a.zipcode}\t#{a.city}\t#{a.state}\t"
          result += "#{a.address}\t#{a.phone_number}\n"
        end
        result
      end
    end

    def validate_print_attributes?(args)
      puts "Sorting by #{args}"
      Attendee.method_defined?(args)
    end

    def initialize
      @current_queue = []
    end

    # returns the count of the queue
    def count
      @current_queue.count
    end

    # loads data into the queue
    def load(data)
      @current_queue = data
    end

    # empties the queue
    def clear
      @current_queue = []
    end

    # saves output to a file name
    def save_to(filename)
      output = File.new(filename, "w")
      output.write(print(DEFAULT_SORT_KEY))
      output.close
      if (File.exists?(filename))
        return "File saved successfully."
      else
        return "File failed to save."
      end
    end

  end
end