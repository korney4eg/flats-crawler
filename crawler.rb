#!/usr/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require './lib/connector-json.rb'
require './lib/logger'

# Crawler class
class FlatCrawler
  include CrLogger
  def initialize(connection)
    @connection = connection
    @rooms = [1]
    @price = [20_000, 60_000]
    @step = 10_000
    # @areas = [32, 33, 36, 40, 41, 43]
    @areas = *(1..5)
    @years = [0, 2_017]
    @keywords = ''
    @page_urls = []
    @active_flats = []
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
      log "New flat:#{address} on area #{area} cost #{price}$ #{rooms} rooms, #{year}", 3
      @connection.add_flat(code, area, address, price, rooms, year)
    elsif price != last_price
      if price < last_price
        status = 'down'
      else
        status = 'up'
      end
      log "Updated flat:#{code} cost from #{last_price} -> #{price}$", 3
      @connection.add_flat_hist(code, price)
      @connection.update_flat(code, price)
    else
      log 'nothing to do', 4
    end
    @connection.update_area(code, area)
  end
  
  def mark_sold
    #puts @active_flats.inspect
    #puts @connection.get_all_flats.inspect
    flats_to_mark_sold = @connection.get_all_flats.keys - @active_flats
    flats_to_mark_sold.each do |flat|
      # @connection.update_status(flat, 'sold')
      puts "#{flat} to mark as sold"
    end
  end
end

# tvoya stalica crawler
class TSCrawler < FlatCrawler
  def initialize(connection)
    @connection = connection
    @rooms = [1]
    @price = [20_000, 60_000]
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
    volgogradskaya-nezavisimosti-sevastopolskaya,
    vostok,
    grushevka,
    dzerzhinskogo-umanskaya-zheleznodorozhnaya,
    zelenyy-lug,
    kalvariyskaya-kharkovskaya-pushkina,
    lebyazhiy,
    makaenka-nezavisimosti-filimonova,
    malinovka,
    masyukovshchina,
    mayakovskogo,
    mendeleeva-stoletova,
    pushkina-glebki-olshevskogo-pritytskogo,
    sedykh-tikotskogo,
    surganova-bedy-bogdanovicha,
    sukharevo,
    uruche,
    tsna,
    chervyakova-shevchenko-kropotkina,
    yugo-zapad
    )
    @years = [0, 2_017]
    @keywords = ''
    @page_urls = []
    @active_flats = []
  end

  def generate_urls
    @areas.each do |area|
      (@price[0]..@price[0]).step(@step) do |pr|
        page_url = 'http://www.t-s.by/buy/flats/filter/'
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
      log "Crawling on URL: #{url}", 4
      area = url.gsub(/=.*$/,'').gsub(/^.*area\[/,'').gsub(']','').to_i
      # page = Nokogiri::HTML(File.open('page_example.html','r'))
      page = Nokogiri::HTML(open(url))
      flats = page.css("div.container .content .col-md-8 #viewcatalog\
           [class='row change-columns'] [class='col-sm-4 col-md-4  map-point']")
      # puts "Number of flats found: #{flats.size}"
      flats.each do |flat|
        address = flat.css('a .caption h4').text
        price = flat.css('a .caption .virtual-tour__priceusd').text.gsub(/[^\d]/, '').to_i
        rooms = flat.css('a .caption .virtual-tour__rooms').text.gsub(/[^\d]/, '')
        year = flat.css('a .caption .virtual-tour__date').text.to_i
        code = flat.css('a')[0]['href'].gsub(/[^\d]/, '').to_i
        update_price(code, area, address, price, rooms, year)
        @active_flats << code
      end
    end
    mark_sold
  end
end

connection = JSONConnector.new('1.json')

ts = TSCrawler.new(connection)
ts.parse_flats
# # ts.full_reindex
connection.close
