#!/usr/bin/ruby -w
require 'mysql2'
require './connector'
# require './logger'
# include Logger
#
class FlatViewer
  def initialize(connection, file_name)
    @connection = connection
    @html_file = file_name
  end

  def render_html(flats, days)
    render_html_header
    render_html_table(flats, days)
    render_html_footer
  end

  def render_html_header
    puts('<HTML> <head><title>Flats</title>')
    puts("<meta http-equiv=\'Content-Type\'
         content=\'text/html; charset=utf-8\'/>")
    puts('</head>')
    puts('<BODY>')
  end

  def render_html_footer
    puts('</BODY>')
    puts('<HTML>')
  end

  def render_html_table_header(days)
    puts('<TABLE border=1>')
    puts("\t<TR>")
    puts("\t\t<TD>#")
    puts("\t\t<TD>Код")
    puts("\t\t<TD>Адрес")
    puts("\t\t<TD>Цена $")
    puts("\t\t<TD>stat")
    puts("\t\t<TD>комнат")
    puts("\t\t<TD>год постройки")
    days.each { |day| puts("\t\t<TD>#{day}") }
  end

  def get_status_symb(status)
    status_char = ''
    if status == 'down'
      status_char = "<span style=\"color:green\">&#8601;</span>"
    elsif status == 'up'
      status_char = "<span style=\"color:red\">&#8598;</span>"
    elsif status == 'new'
      status_char = "<span style=\"color:yellow\">&#8687;</span>"
    else
      status_char = '&nbsp;'
    end
  end

  def generate_days(days)
    days_arr = []
    days.each do |day|
      if info['history'].keys.include? day
        days_arr += [info['history'][day]]
      else
        days_arr += ['-']
      end
    end
  end

  def render_html_table_line(num, code, info)
    generate_days(days)
    puts("\t<TR>")
    puts("\t\t<TD>#{num}")
    puts("\t\t<TD>#{code}")
    puts("\t\t<TD><a href='http://www.t-s.by/buy/flats/#{code}'"\
         " >#{info['address']}</a>")
    puts("\t\t<TD>#{info['price']}$")
    puts("\t\t<TD>#{get_status_symb(info['status'])}")
    puts("\t\t<TD>#{info['rooms']}")
    puts("\t\t<TD>#{info['year']}")
    days_arr.each { |day| puts("\t\t<TD>#{day}") }
  end

  def render_html_table(flats, days)
    render_html_table_header(days)
    i = 0
    flats.each_pair do |code, info|
      i += 1
      render_html_table_line(i, code, info)
    end
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

  def collect_flats
    dates = con.query('SELECT distinct date from price_history order by date desc;')
    days = []
    i = 0
    flats = {}
    con.query('SELECT * from global where area in (32, 33, 36, 40, 41, 43) ORDER BY price;').each do |sets|
      i += 1
      flats[sets['code']] = { 'address' => sets['address'],
                              'price'  => sets['price'],
                              'rooms'  => sets['rooms'],
                              'year'   => sets['year'],
                              'status'   => sets['status'],
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
  end
end

connection = DBConnector.new('localhost', 'flats', 'flat', 'flat')
  render_html(flats, days)
