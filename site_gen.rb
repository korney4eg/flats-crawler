#!/usr/bin/ruby -w
require 'mysql2'

$LOG_LEVEL = 3 # 1 - errors, 2 - warnings, 3 - info, 4 - debug, 5 - trace

def log(message, level = 3)
  puts message if level <= $LOG_LEVEL
end

def render_html(flats, days)
  i = 0
  puts('<HTML> <head><title>Flats</title>')
  puts("<meta http-equiv=\'Content-Type\'
       content=\'text/html; charset=utf-8\'/>")
  puts('</head>')
  puts('<BODY>')
  puts('<TABLE border=1>')
  puts('\t<TR>')
  puts('\t\t<TD>#')
  puts('\t\t<TD>Код')
  puts('\t\t<TD>Адрес')
  puts('\t\t<TD>Цена $')
  puts('\t\t<TD>комнат')
  puts('\t\t<TD>год постройки')
  days.each { |day| puts("\t\t<TD>#{day}") }
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
    puts("\t<TR>")
    puts("\t\t<TD>#{i}")
    puts("\t\t<TD>#{code}")
    puts("\t\t<TD>#{info['address']}")
    puts("\t\t<TD>#{info['price']}$")
    puts("\t\t<TD>#{info['rooms']}")
    puts("\t\t<TD>#{info['year']}")
    days_arr.each { |day| puts("\t\t<TD>#{day}") }
  end
  puts('</BODY>')
  puts('<HTML>')
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
        days_arr += [' -- ']
      end
    end
    printf(table, i, code, info['address'], info['price'],
           info['rooms'], info['year'], *days_arr)
  end
end

con = Mysql2::Client.new(host: 'localhost', username: 'flat',
                         password: 'flat', database: 'flats')
dates = con.query('SELECT distinct date from price_history order by date desc;')
days = []
i = 0
flats = {}
con.query('SELECT * from global ORDER BY price;').each do |sets|
  i += 1
  flats[sets['code']] = { 'address' => sets['address'],
                          'price'  => sets['price'],
                          'rooms'  => sets['rooms'],
                          'year'   => sets['year'],
                          'history' => {} }
  dates.each do |d|
    days += [d['date']] unless days.include? d['date']
    prices = con.query("SELECT price,date from price_history
                       where code = #{sets['code']} order by date desc;")
    prices.each do |pr|
      if pr['date'] == d['date']
        flats[sets['code']]['history'][d['date']] = pr['price']
      end
    end
  end
end
render_html(flats, days)
