#!/usr/bin/ruby -w
# encoding: utf-8
#require 'mysql2'
require './lib/connector-json.rb'
require 'erb'

def get_changing_dates(flats)
  changing_dates = []
  flats.values.each do |flat|
    # puts flat['history']
    flat['history'].keys.each do |date|
      changing_dates << date if not changing_dates.include?(date)
    end
  end
  changing_dates
end

def get_sold_flats(flats)
  sold_flats = flats.select {|code, info| info['sold_date']}
  sold_flats.each_pair do |sold_code, sold_info|
    history = sold_info['history']
    sold_info['selling_start_date'] = history.keys.min
    sold_info['selling_start_price'] = history[sold_info['selling_start_date']]
  end
  return sold_flats
end

def get_active_flats(flats)
  i = 0
  active_flats = flats.select {|code, info| !info['sold_date'] }
  active_flats.each_pair do |code, info|
    i += 1
    days_arr = []
    days = get_changing_dates(active_flats)
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
  return active_flats
end

def get_flats_status(flats_info, date)
  if flats_info['history'].keys.include?(date)
    flat_dates = flats_info['history'].keys.sort
    date_position = flat_dates.index(date)
    if date_position == 0
      status = '<p style="color:orange">добавлена'
    elsif date == flats_info['sold_date']
      status = '<p style="color:grey">продана'
    else
      current_price = flats_info['history'][date]
      previous_price = flats_info['history'][flat_dates[date_position - 1]]
      if current_price > previous_price
        status = '<p style="color:red">подорожала'
      else
        status = '<p style="color:green">подешевела'
      end
      status += " с #{previous_price}$ до #{current_price}$"
    end
    status += '</p>'
  end
  return status
end


def render_from_template(flats, template_name, output_file_name='flats.html')
  sold_flats = get_sold_flats(flats)
  active_flats = get_active_flats(flats)
  days = get_changing_dates(active_flats).sort{|x,y| y <=> x}

  template = File.read("./templates/#{template_name}")
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

flats = connection.get_all_flats.select{|code, info|\
          info['year'] > 1990 &&\
          info['address'].include?('Минск') &&\
          info['rooms'].to_i >= 1 }
# puts "Dates are: #{ dates }"
input_array = ARGV
if input_array.size > 0
  input_array.each do |output_file|
    render_from_template(flats,'flats.html.erb', output_file)
  end
else
  render_from_template(flats,'flats.html.erb')
end
