#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'mysql2'

$LOG_LEVEL = 3 # 1 - errors, 2 - warnings, 3 - info, 4 - debug, 5 - trace

def log(message, level = 3)
  puts message if level <= $LOG_LEVEL
end

con = Mysql2::Client.new(host: 'localhost', username: 'flat',
                         password: 'flat', database: 'flats')

def update_price(con, code, address, price, rooms, year)
  rs = con.query("SELECT code,price from global where code=#{code};")
  time = Time.new
  if rs.size == 0
    con.query("INSERT INTO global(code,address,price,rooms,year)
              VALUES (#{code},\'#{address}\',#{price},\"#{rooms}\",#{year});")
    con.query("INSERT INTO price_history VALUES
              (#{code},#{price},\"#{time.year}-#{time.month}-#{time.day}\");")
  elsif con.query("SELECT code,price from price_history
                  where code=#{code};").first['price'].to_i != price
    log "INSERT INTO price_history VALUES
          (#{code},#{price},\"#{time.year}-#{time.month}-#{time.day}\");", 4
    con.query("INSERT INTO price_history VALUES
              (#{code},#{price},\"#{time.year}-#{time.month}-#{time.day}\");")
    log "UPDATE global SET price=#{price} WHERE code = #{code});", 4
    con.query("UPDATE global SET price=#{price} WHERE code = #{code});")
  else
    log 'nothing to do', 4
  end
end
ROOMS = [1, 2]
PRICE = [20_000, 140_000]
STEP = 10_000
AREAS = [32, 33, 36, 40, 41, 43]
YEARS = [0, 2_016]
KEYWORDS = ''

(PRICE[0]..PRICE[1]).step(STEP) do |pr|
  page_url = 'http://www.t-s.by/buy/flats/?'
  ROOMS.each { |room| page_url += "rooms[#{room}]=#{room}&" }
  AREAS.each { |area| page_url += "area[#{area}]=#{area}&" }
  page_url += 'daybefore=1&'
  page_url += "year[min]=#{YEARS[0]}&year[max]=#{YEARS[1]}&"

  page_url += "price[min]=#{pr}&price[max]=#{pr + STEP}&keywords="
  puts page_url
  page = Nokogiri::HTML(open(page_url))
  flats = page.css('div#pager-top').css('li')
  flats.each do |flat|
    address = flat.css('td[class=address]').css('span').text
    price = flat.css('td[class=price]').text.sub('$', '').gsub(' ', '').to_i
    rooms = flat.css('td[class=rooms]').text.gsub(' ', '').gsub(/\t/, '').sub(/\n/, '')
    year = flat.css('td[class=year]').text.to_i
    code = flat.css('td[class=code]').text.to_i
    update_price(con, code, address, price, rooms, year)
  end
end
con.close if con
