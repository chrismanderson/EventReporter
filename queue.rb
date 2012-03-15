module EventReporter
  class Queue
    SAMPLE_QUEUE = %w{doing some of this stuff is super hard and shit}
    OUTPUT_HEADERS = ['LAST NAME', 'FIRST NAME', 'EMAIL',
            'ZIPCODE', 'CITY', 'STATE', 'ADDRESS']
    DEFAULT_SORT_KEY = "reg_date"

    attr_accessor :current_queue

    def initialize
      @current_queue = SAMPLE_QUEUE
    end

    def print(parameters = DEFAULT_SORT_KEY)
      result = "#{OUTPUT_HEADERS.join("\t")}\n"
      puts "I'm printing by #{parameters}"
      temp_queue = @current_queue.sort_by { |hsh| hsh.send(parameters) }
      temp_queue.each do |attendee|
        result += "#{attendee.last_name}\t#{attendee.first_name}\t#{attendee.email}\t"
        result += "#{attendee.zipcode}\t#{attendee.city}\t#{attendee.state}\t"
        result += "#{attendee.address}\n"
      end
      result
    end

    def count
      @current_queue.count
    end

    def load(data)
      @current_queue = data
    end

    def clear
      @current_queue = []
    end

    def save_to(filename)
      output = File.new(filename, "w")
      status = output.write(print(DEFAULT_SORT_KEY))
      output.close
      if (File.exists?(filename))
        return "File saved successfully."
      else
        return "File failed to save."
      end
    end

  end
end