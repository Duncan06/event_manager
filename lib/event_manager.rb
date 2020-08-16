require "csv"
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
    
    zipcode.to_s.rjust(5,"0")[0..4]

end

def legislators_by_zip(zipcode)

    civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new

    civic_info.key = 'AIzaSyB-AcLbOQeD33OPWKs5gcQxNXGgY8I0WnE'


    begin

        legislators = civic_info.representative_info_by_address(
                        address: zipcode, 
                        levels: 'country', 
                        roles: ['legislatorUpperBody', 'legislatorLowerBody']
                      ).officials

    rescue

        "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"

    end

end

def save_thank_you_letter(id,form_letter)

    Dir.mkdir("output") unless Dir.exists? "output"

    filename = "output/thanks_#{id}.html"

    File.open(filename, 'w') do |file|

        file.puts form_letter
    
    end

end

def clean_number(phone_number)

    phone_num =  phone_number.to_s.scan(/\d+/).join()

    if phone_num.nil?

        "N/A"

    elsif phone_num.length == 10

        phone_num

    elsif phone_num.length == 11

        if phone_num[0] == 1 

            phone_num

        elsif phone_num[0] == "("

            phone_num[1] == 1 ? phone_num[2..11] : "N/A"

        else 

            "N/A"

        end

    else

        "N/A"

    end

end

def get_hours(day)

    day.hour

end



puts "EventManager Initialized!"

template_letter = File.read "form_letter.erb"

erb_template = ERB.new template_letter

contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol

hours = []

week_days = []

contents.each do |row|

    # id = row[0]

    # name = row[:first_name]

    timestamp = DateTime.strptime(row[:regdate].to_s, '%m/%d/%Y %H:%M')

    hours << timestamp.hour

    week_days << timestamp.wday

    # phone = clean_number(row[:homephone])
 
    # zipcode = clean_zipcode(row[:zipcode])

    # legislators = legislators_by_zip(zipcode)
    
    # form_letter = erb_template.result(binding)

    # save_thank_you_letter(id, form_letter)

end

highest_hours = {}

highest_days = {}

hours.each{ |h| highest_hours.key?(h) ? highest_hours[h] += 1 : highest_hours[h] = 1}

week_days.each{ |h| highest_days.key?(h) ? highest_days[h] += 1 : highest_days[h] = 1}

puts "Highest hours"
p highest_hours.sort_by { |k, v| [-v, k] }

puts "Highest days"
p highest_days.sort_by { |k, v| [-v, k] }

puts File.exist? "event_attendees.csv"