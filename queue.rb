require './attendee'
require 'csv'

module EventReporter
  class Queue
    DEFAULT_SORT_KEY = "reg_date"

    attr_accessor :current_queue
    # prints the tab deliminated list
    # sorts by reg_date by default, otherwise takes an argument to sort
    def print(parameters)
      if parameters == "print" then parameters = DEFAULT_SORT_KEY end
      result = "#{output_headers.join("\t")}\n"
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

    def output_headers
      return %w(LAST\ NAME FIRST\ NAME EMAIL ZIPCODE CITY STATE STREET)
    end

    # saves output to a file name
    def save_to(filename)
      output = CSV.open(filename, "w")
      output << output_fields
      @current_queue.each do |record|
      output << [record.last_name, record.first_name, record.email,
        record.zipcode, record.city, record.state, record.street]
      end
      output.close
      if (File.exists?(filename))
        return "File saved successfully."
      else
        return "File failed to save."
      end
    end
  end
end