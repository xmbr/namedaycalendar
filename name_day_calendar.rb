#!/usr/bin/env ruby

require 'nokogiri'
require 'date'
require 'open-uri'

class NameDayCalendar
  MONTHS = %w(january february march april may june july august september october november december)
  URL = 'http://www.namedaycalendar.com'

  attr_accessor :month, :day

  def initialize(month, day)
    @month, @day = month, day
  end

  def get_name_days
    validate_params
    parse_name_days(open("#{URL}/#{month}/#{day}"))
  end

  def print_name_days
    name_days = get_name_days

    puts "#{month.upcase}/#{day}"
    puts '-' * 20
    name_days.each_pair do |country, names|
      puts "| #{country} => " + names.join(', ')
    end
    puts '-' * 20
  end

  private

  def parse_name_days(body)
    name_days = Hash.new

    Nokogiri::HTML(body).search('td.calendarday div.country').each do |country|
      country_name = country.at('b').text.strip
      name_days[country_name] = Array.new

      country.search('div').each do |name|
        next if name.has_attribute?('class')
        name_days[country_name] << name.text.strip
      end
    end

    name_days
  end

  def validate_params
    raise InvalidMonth unless MONTHS.include?(month)
    raise InvalidRange unless Date.valid_date?(
      Date.today.year,
      MONTHS.find_index(month.downcase)+1,
      day)
  end

  class InvalidMonth < ArgumentError
    def to_s; "month must be one of: #{MONTHS.join ', '}" end
  end

  class InvalidRange < ArgumentError
    def to_s; "day out of range" end
  end
end

# run it
if __FILE__ == $0

  def print_help(msg)
    puts <<-EOF
usage: #{$0} MONTH DAY
please enter correct #{msg}.
    EOF
  end

  begin
    NameDayCalendar.new(ARGV[0].downcase, ARGV[1].to_i).print_name_days
  rescue NameDayCalendar::InvalidMonth
    print_help('month')
  rescue NameDayCalendar::InvalidRange
    print_help('day of month')
  rescue Exception
    print_help('month and day')
  end

end
