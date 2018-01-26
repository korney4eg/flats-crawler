#!/usr/bin/ruby
# encoding: utf-8

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require './lib/connector-json.rb'
require 'logger'

# Crawler class
class FlatCrawler
  def initialize(connection)
    @connection = connection
    read_configuration
    configre_logging
    @logger.info '=================================================='
    
  end

  def read_configuration
  end

  def configre_logging
    file = File.open('./logs/crawler.log', 'a')
    @logger = Logger.new(file)
    @logger.level = Logger::INFO
    @logger.formatter = proc do |severity, datetime, progname, msg|
      "#{datetime}|  #{severity}: #{msg}\n"
    end
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
    code_found = @connection.found_code?(code)
    last_price = @connection.get_last_price(code)
    if !code_found
      @logger.info "New flat:#{address} on area #{area} cost #{price}$ #{rooms} rooms, #{year}"
      @connection.add_flat(code, area, address, price, rooms, year)
    elsif price != last_price
      if price < last_price
        status = 'down'
      else
        status = 'up'
      end
      @logger.info "Updated flat:#{code} cost from #{last_price} -> #{price}$"
      @connection.add_flat_hist(code, price)
      @connection.update_flat(code, price)
    else
      @logger.debug'nothing to do'
    end
    @connection.update_area(code, area)
  end
  
  def mark_sold
    flats_to_mark_sold = @connection.get_all_flats.keys.sort - @active_flats.sort
    @logger.info "number of active flats is #{@active_flats.size} flats"
    @logger.info "Will mark as sold #{flats_to_mark_sold.size} flats"
    # flats_to_mark_sold.each do |flat|
    #    @connection.update_status(flat, 'sold')
    #    @logger.info "#{flat} to mark as sold"
    # end
  end
end

# tvoya stalica crawler
class TSCrawler < FlatCrawler
  def read_configuration
    @rooms = [1,2,3]
    @price = [20_000, 100_000]
    @step = 10_000
    # Areas should be a list of areas,
    # here is the full list:
    # "avtozavod",  "akademiya-nauk",  "angarskaya",
    # "aerodromnaya-mogilevskaya-voronyanskogo", "brilevichi-druzhba",
    # "velozavod", "vesnyanka", "voennyy-gorodok-uruche",
    # "volgogradskaya-nezavisimosti-sevastopolskaya", "vostok", "grushevka",
    # "dzerzhinskogo-umanskaya-zheleznodorozhnaya", "dombrovka",  "z-gorka-pl-ya-kolasa",
    # "zavodskoy-rayon", "zapad", "zelenyy-lug",
    # "kalvariyskaya-kharkovskaya-pushkina", "kamennaya-gorka",
    # "kirova-marksa", "kozlova-zakharova", "komarovka",
    # "kommunisticheskaya-storozhevskaya-opernyy", "kuntsevshchina",
    # "kurasovshchina-", "lebyazhiy", "leninskiy-rayon", "loshitsa",
    # "makaenka-nezavisimosti-filimonova", "malinovka", "malyy-trostenets",
    # "masyukovshchina", "mayakovskogo", "mendeleeva-stoletova",
    # "mikhalovo", "moskovskiy-rayon", "odoevskogo-pushkina-pritytskogo",
    # "oktyabrskiy-rayon", "partizanskiy-rayon", "pervomayskiy-rayon",
    # "prigorod", "pushkina-glebki-olshevskogo-pritytskogo",
    # "r-lyuksemburg-k-libknekhta-rozochka",
    # "romanovskaya-sloboda-gorodskoy-val-myasnikova", "sedykh-tikotskogo",
    # "serebryanka", "serogo-asanalieva", "sovetskiy-rayon", "sokol",
    # "stepyanka", "surganova-bedy-bogdanovicha", "sukharevo",
    # "timiryazeva-pobediteley-masherova", "traktornyy-zavod",
    # "univermag-belarus", "uruche", "frunzenskiy-rayon",
    # "tsentralnyy-rayon", "tsna", "chervyakova-shevchenko-kropotkina",
    # "chizhovka", "shabany", "yugo-zapad"
     
    @areas = %w(
    akademiya-nauk
    aerodromnaya-mogilevskaya-voronyanskogo
    brilevichi-druzhba
    volgogradskaya-nezavisimosti-sevastopolskaya
    vostok
    grushevka
    dzerzhinskogo-umanskaya-zheleznodorozhnaya
    zelenyy-lug
    kalvariyskaya-kharkovskaya-pushkina
    lebyazhiy
    makaenka-nezavisimosti-filimonova
    malinovka
    masyukovshchina
    mayakovskogo
    mendeleeva-stoletova
    pushkina-glebki-olshevskogo-pritytskogo
    sedykh-tikotskogo
    surganova-bedy-bogdanovicha
    sukharevo
    uruche
    tsna
    chervyakova-shevchenko-kropotkina
    yugo-zapad
    )
    @years = [0, 2_018]
    @keywords = ''
    @page_urls = []
    @active_flats = []
  end

  def generate_urls
    @areas.each do |area|
      (@price[0]..@price[0]).step(@step) do |pr|
        page_url = 'https://www.t-s.by/buy/flats/filter/'
        page_url += "district-is-#{area}/"
        # page_url += 'daybefore=1&'
        # page_url += "year[min]=#{@years[0]}&year[max]=#{@years[1]}&"
        # page_url += "price[min]=#{pr}&price[max]=#{pr + @step}&keywords="
        @page_urls += [page_url]
      end
    end
  end

  def parse_flats
    generate_urls
    @page_urls.each do |url|
      @logger.info "Crawling on URL: #{url}"
      area = url.gsub(/=.*$/,'').gsub(/^.*area\[/,'').gsub(']','').to_i
      page = Nokogiri::HTML(open(url))
      flats = page.css("div.container .content .col-md-8 #viewcatalog")
      flats = flats.css("[class='row change-columns']")
      flats = flats.css("[class='col-sm-4 col-md-4  map-point']")
      @logger.info "Number of flats found: #{flats.size}"
      flats.each do |flat|
        address = flat.css('a .caption h4').text
        price = flat.css('a .caption .virtual-tour__priceusd').text.gsub(/[^\d]/, '').to_i
        rooms = flat.css('a .caption .virtual-tour__rooms').text.gsub(/[^\d]/, '')
        year = flat.css('a .caption .virtual-tour__date').text.to_i
        code = flat.css('a')[0]['href'].gsub(/[^\d]/, '')
        update_price(code, area, address, price, rooms, year)
        @logger.debug "Checking: |#{address}|#{rooms}|#{year}| -- #{price} $"
        @active_flats << code
      end
      # @logger.info "Updated #{@active_flats.size}/#{flats.size}"
    end
    mark_sold
  end
end

connection = JSONConnector.new('1.json')

ts = TSCrawler.new(connection)
ts.parse_flats
# # ts.full_reindex
connection.close
