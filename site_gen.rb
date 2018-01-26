#!/usr/bin/ruby -w
# encoding: utf-8
#require 'mysql2'
require './lib/connector-json.rb'
# require './logger'
# include Logger

def render_html(flats, days,output_file='flats.html')
  i = 0
  file = File.open(output_file, 'a')
  file.write('<HTML> <head><title>Flats</title>')
  file.write("<meta http-equiv=\'Content-Type\'
       content=\'text/html; charset=utf-8\'/>")
  file.write('</head>')
  file.write('<BODY>')
  file.write('<TABLE border=1>')
  file.write("\t<TR>")
  file.write("\t\t<TD>#")
  file.write("\t\t<TD>Код")
  file.write("\t\t<TD>Адрес")
  file.write("\t\t<TD>Цена $")
  file.write("\t\t<TD>stat")
  file.write("\t\t<TD>комнат")
  file.write("\t\t<TD>год постройки")
  days.each { |day| file.write("\t\t<TD>#{day}") }
  flats.each_pair do |code, info|
    # file.write "checking flat #{code}"
    i += 1
    days_arr = []
    days.each do |day|
      if info['history'].keys.include? day
        days_arr += [info['history'][day]]
      else
        days_arr += ['-']
      end
    end
    file.write("\t<TR>")
    file.write("\t\t<TD>#{i}")
    file.write("\t\t<TD>#{code}")
    file.write("\t\t<TD><a href='http://www.t-s.by/buy/flats/#{code}/'"\
         " >#{info['address']}</a>")
    status_char = ''
    if info['status'] == 'down'
      status_char = "<span style=\"color:green\">&#8601;</span>"
    elsif info['status'] == 'up'
      status_char = "<span style=\"color:red\">&#8598;</span>"
    elsif info['status'] == 'new'
      status_char = "<span style=\"color:yellow\">&#8687;</span>"
    elsif info['status'] == 'sold'
      status_char = "<span style=\"color:blue\">&#8364;</span>"
    else
      status_char = '&nbsp;'
    end
    file.write("\t\t<TD>#{info['price']}$")
    file.write("\t\t<TD>#{status_char}")
    file.write("\t\t<TD>#{info['rooms']}")
    file.write("\t\t<TD>#{info['year']}")
    days_arr.each { |day| file.write("\t\t<TD>#{day}") }
  end
  file.write('</BODY>')
  file.write('<HTML>')
  file.close()
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
dates = connection.get_dates
# puts "Dates are: #{ dates }"
render_html(flats, dates)
