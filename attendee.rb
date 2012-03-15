module EventReporter
  class Attendee

    INVALID_DATA = "INVALID_DATA"
    attr_accessor :last_name, :first_name, :email,
    :zipcode, :city, :state, :address, :phone_number, :street, :reg_date

    OUTPUT_HEADERS = ['LAST NAME', 'FIRST NAME', 'EMAIL',
            'ZIPCODE', 'CITY', 'STATE', 'ADDRESS']
    def initialize(attributes)
      @first_name = fix(attributes[:first_name])
      @last_name = fix(attributes[:last_name])
      @phone_number = clean_phone(attributes[:homephone])
      @state = fix(attributes[:state])
      @email = fix(attributes[:email_address])
      @city = fix(attributes[:city])
      @reg_date = fix(attributes[:regdate])
      @street = fix(attributes[:street])
      @zipcode = clean_zip(attributes[:zipcode])
    end

    # outputs an array of valid attributes (a pseudo api)
    # for other classes to call
    def self.valid_list
      return %w{phone_number first_name last_name zip_code
                legislators reg_date email street city state}
    end

    # method to grab a full name
    def full_name
      [first_name, last_name].join(' ')
    end

    # cleans up zip codes
    def clean_zip(dirty_zip)
      dirty_zip.to_s.rjust(5, '0')
    end

    # prints a full address
    def address
      "#{@address} #{@city} #{@state}"
    end

    # cleans a phone number and makes it purty
    def clean_phone(dirty_phone)
        phone_number = dirty_phone.scan(/\d/).join
        "(#{phone_number[0..2]}) #{phone_number[3..5]}-#{phone_number[6..-1]}"
    end

    # dirty fix to repair data
    # checks for nil data and inserts a dummy value if it's nil
    def fix(dirty)
      if dirty.nil?
        INVALID_DATA
      else
        dirty.capitalize
      end
    end

  end
end