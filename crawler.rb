#!/usr/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require './connector'
require './logger'

# Crawler class
class FlatCrawler
  include CrLogger
  def initialize(connection)
    @connection = connection
    @rooms = [1, 2]
    @price = [20_000, 140_000]
    @step = 10_000
    @areas = [32, 33, 36, 40, 41, 43]
    @years = [0, 2_016]
    @keywords = ''
    @page_urls = []
  end

  def parse_flats
  end

  def save_flats
  end

  def generate_urls
  end

  def update_price(code, address, price, rooms, year)
    if !@connection.code_found(code)
      log "New flat:#{address} cost #{price}$ #{rooms} rooms, #{year}" , 3
      @connection.add_flat(code, address, price, rooms, year)
      @connection.add_flat_hist(code, price)
    elsif price != @connection.get_last_price(code)
      log "Updated flat:#{code} cost #{price}$" , 3
      @connection.add_flat_hist(code, price)
      @connection.update_flat(code, price)
    else
      log 'nothing to do', 4
    end
  end
end

# tvoya stalica crawler
class TSCrawler < FlatCrawler
  def generate_urls
    (@price[0]..@price[1]).step(@step) do |pr|
      page_url = 'http://www.t-s.by/buy/flats/?'
      @rooms.each { |room| page_url += "rooms[#{room}]=#{room}&" }
      @areas.each { |area| page_url += "area[#{area}]=#{area}&" }
      page_url += 'daybefore=1&'
      page_url += "year[min]=#{@years[0]}&year[max]=#{@years[1]}&"
      page_url += "price[min]=#{pr}&price[max]=#{pr + @step}&keywords="
      @page_urls += [page_url]
    end
  end

  def parse_flats
    generate_urls
    @page_urls.each do |url|
      log "Crawling on URL: #{url}",4
      page = Nokogiri::HTML(open(url))
      flats = page.css('div#pager-top').css('li')
      flats.each do |flat|
        address = flat.css('td[class=address]').css('span').text
        price = flat.css('td[class=price]').text.sub('$', '').gsub(' ', '').to_i
        rooms = flat.css('td[class=rooms]').text.gsub(' ', '').gsub(/\t/, '').sub(/\n/, '')
        year = flat.css('td[class=year]').text.to_i
        code = flat.css('td[class=code]').text.to_i
        update_price(code, address, price, rooms, year)
      end
    end
  end
end

connection = DBConnector.new('localhost', 'flats', 'flat', 'flat')

ts = TSCrawler.new(connection)
ts.parse_flats
connection.close
