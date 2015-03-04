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
    #@areas = [32, 33, 36, 40, 41, 43]
    @areas = *(1..67)
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

  def full_reindex
    flats_from_hist = @connection.get_history
    all_codes = {}
    status = {}
    flats_from_hist.each_pair do |date, flats|
      flats.each do |flat|
        flat.each_pair do |code, price|
          if all_codes.keys.include?(code)
            if all_codes[code] > price
              status[code] = 'down'
            elsif all_codes[code] < price
              status[code] = 'up'
            end
          else
            status[code] = 'new'
          end
          if flats_from_hist.values.last != date && status[code] == 'new'
            status[code] = ''
          end
          all_codes[code] = price
        end
      end
    end
    all_codes.each_pair { |code, price|  @connection.update_flat(code, price, status[code]) }
  end

  def update_price(code, area, address, price, rooms, year)
    code_found = @connection.code_found(code)
    last_price = @connection.get_last_price(code)
    if !code_found
      log "New flat:#{address} on area #{area} cost #{price}$ #{rooms} rooms, #{year}", 3
      @connection.add_flat(code, area, address, price, rooms, year)
      @connection.add_flat_hist(code, price)
    elsif price != last_price
      if price < last_price
        status = 'down'
      else
        status = 'up'
      end
      log "Updated flat:#{code} cost from #{last_price} -> #{price}$", 3
      @connection.add_flat_hist(code, price)
      @connection.update_flat(code, price, status)
    else
      log 'nothing to do', 4
    end
    @connection.update_area(code, area)
  end
end

# tvoya stalica crawler
class TSCrawler < FlatCrawler
  def generate_urls
    @areas.each do |area|
      (@price[0]..@price[1]).step(@step) do |pr|
        page_url = 'http://www.t-s.by/buy/flats/?'
        # @rooms.each { |room| page_url += "rooms[#{room}]=#{room}&" }
        page_url += "area[#{area}]=#{area}&"
        page_url += 'daybefore=1&'
        page_url += "year[min]=#{@years[0]}&year[max]=#{@years[1]}&"
        page_url += "price[min]=#{pr}&price[max]=#{pr + @step}&keywords="
        @page_urls += [page_url]
      end
    end
  end

  def parse_flats
    generate_urls
    @page_urls.each do |url|
      log "Crawling on URL: #{url}", 4
      area = url.gsub(/=.*$/,'').gsub(/^.*area\[/,'').gsub(']','').to_i
      page = Nokogiri::HTML(open(url))
      flats = page.css('div#pager-top').css('li')
      flats.each do |flat|
        address = flat.css('td[class=address]').css('span').text
        price = flat.css('td[class=price]').text.sub('$', '').gsub(' ', '').to_i
        rooms = flat.css('td[class=rooms]').text.gsub(' ', '').gsub(/\t/, '').sub(/\n/, '')
        year = flat.css('td[class=year]').text.to_i
        code = flat.css('td[class=code]').text.to_i
        update_price(code, area, address, price, rooms, year)
      end
    end
  end
end

connection = DBConnector.new('localhost', 'flats', 'flat', 'flat')

ts = TSCrawler.new(connection)
ts.parse_flats
# ts.full_reindex
connection.close
