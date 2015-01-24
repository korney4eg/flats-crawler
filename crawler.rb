#!/usr/bin/ruby -w

require 'rubygems'
require 'nokogiri'
require 'open-uri'
load 'connector.rb'

$LOG_LEVEL = 4 # 1 - errors, 2 - warnings, 3 - info, 4 - debug, 5 - trace

def log(message, level = 3)
  puts message if level <= $LOG_LEVEL
end

connection = DBConnector.new('localhost', 'flats', 'flat', 'flat')

def update_price(db, code, address, price, rooms, year)
  if !db.code_found(code)
    db.add_flat(code, address, price, rooms, year)
    db.add_flat_hist(code, price)
  elsif price != db.get_last_price(code)
    db.add_flat_hist(code, price)
    db.update_flat(code, price)
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
  page = Nokogiri::HTML(open(page_url))
  flats = page.css('div#pager-top').css('li')
  flats.each do |flat|
    address = flat.css('td[class=address]').css('span').text
    price = flat.css('td[class=price]').text.sub('$', '').gsub(' ', '').to_i
    rooms = flat.css('td[class=rooms]').text.gsub(' ', '').gsub(/\t/, '').sub(/\n/, '')
    year = flat.css('td[class=year]').text.to_i
    code = flat.css('td[class=code]').text.to_i
    update_price(connection, code, address, price, rooms, year)
  end
end
connection.close
