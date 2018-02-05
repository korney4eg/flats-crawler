#!/usr/bin/ruby -w
# encoding: utf-8
#require 'mysql2'
require './lib/connector-json.rb'
require 'erb'

def render_from_template(flats, days, template_name, output_file_name='flats.html')
  i = 0
  template = File.read("./templates/#{template_name}")
  flats.select! {|code, info| info['status'] != 'sold'}
  flats.each_pair do |code, info|
    i += 1
    days_arr = []
    days.each do |day|
      if info['history'].keys.include? day
        days_arr += [info['history'][day]]
      else
        days_arr += ['-']
      end
    end
    info['price_changes'] = days_arr
    info['index'] = i
  end
  output_file = File.new( output_file_name, 'w')
  output_file.write ERB.new(template,nil, "%<>").result(binding)
end

def render(flats, days)
  i = 0
  head = '|%3s|%8s|%50s|%10s $|%6s|%6s|'
  table = '|%3d|%8d|%50s|%10d $|%6s|%6d|'
  days.each do
    head += '%12s|'
    table += '%12s|'
  end
  head += '\n'
  table += '\n'
  printf(head, '#', 'code', 'Address', 'Price', 'Rooms', 'Year', *days)
  flats.each_pair do |code, info|
    i += 1
    days_arr = []
    days.each do |day|
      if info['history'].keys.include? day
        days_arr += [info['history'][day]]
      else
        days_arr += [' ']
      end
    end
    printf(table, i, code, info['address'], info['price'],
           info['rooms'], info['year'], *days_arr)
  end
end

# con = Mysql2::Client.new(host: 'localhost', username: 'flat',
#                          password: 'flat', database: 'flats')
connection = JSONConnector.new('1.json')

flats = connection.get_all_flats
dates = connection.get_dates.sort
# puts "Dates are: #{ dates }"
input_array = ARGV
if input_array.size > 0
  input_array.each do |output_file|
    render_from_template(flats, dates,'flats.html.erb', output_file)
  end
else
  render_from_template(flats, dates,'flats.html.erb')
end
