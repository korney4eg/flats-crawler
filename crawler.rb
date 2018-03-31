#!/usr/bin/ruby
# encoding: utf-8

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require './lib/connector-json.rb'
require 'logger'
require 'net/http'

def send_message(message)
  bot_token = ENV['BOT_TOKEN'] || 'unset'
  chat_id = ENV['CHAT_ID']|| 'unset'

  if bot_token != 'unset' and chat_id != 'unset'
    req = Net::HTTP.post_form(URI.parse("https://api.telegram.org/bot#{bot_token}/sendMessage"), {"parse_mode" => "markdown","chat_id" => chat_id,"text" => message})
#    puts req.body
  end
end


# Crawler class
class FlatCrawler
  def initialize(connection)
    @connection = connection
    read_configuration
    configre_logging
    @logger.info "==================================================\n\n\n\n\n"
    @messages = { 'New flats:' => [], 'Updated flats:' => [], 'Sold flats:' => [] }
    
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

  def get_messages
    return @messages
  end


  def update_price(code, area, address, price, rooms, year)
    code_found = @connection.found_code?(code)
    last_price = @connection.get_last_price(code)
    if !code_found
      @logger.info "New flat:#{address} on area #{area} cost #{price}$ #{rooms} rooms, #{year}"
      @messages['New flats:'] << "[ #{address} ](https://www.t-s.by/buy/flats/#{code}) ,cost #{price}\$ #{rooms} rooms, #{year}"
      @connection.add_flat(code, area, address, price, rooms, year)
    elsif price != last_price
      @logger.info "Updated flat:#{code} cost from #{last_price} -> #{price}$"
      messages['Updated flats:'] << "#{code} cost from #{last_price} -> #{price}$"
      @connection.add_flat_hist(code, price)
      @connection.update_flat(code, price)
    else
      @logger.debug'nothing to do'
    end
    @connection.mark_unsold(code)
    @connection.update_area(code, area)
  end
  
  def mark_sold
    flats_to_mark_sold = @connection.get_all_flats.keys.sort - @active_flats.sort
    @logger.info "number of active flats is #{@active_flats.size} flats"
    # @logger.info "Will mark as sold #{flats_to_mark_sold.size} flats"
    flats_to_mark_sold.each do |flat|
       if @connection.mark_sold(flat)
         @logger.info "#{flat} to mark as sold"
         messages['Sold flats:'] << "#{code} sold with price #{price}$"
       end
    end
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
      flats = page.search('[class="flist__maplist-item paginator-item"]')
      @logger.info "Number of flats found: #{flats.size}"
      flats.each do |flat|
        address = flat.css('[class="flist__maplist-item-props-name"]').text.gsub(/^[^,]*, /, '').gsub(/ *$/,'').strip
        price = flat.css('[class="flist__maplist-item-props-price-usd"]').text.gsub(/[^\d]*/,'').to_i
        rooms = flat.css('[class="flist__maplist-item-props-name"]').text.gsub(/-.*$/,'').to_i
        year = flat.css('[class="flist__maplist-item-props-years"]').text.to_i
        code = flat.css('a')[0]['href'].gsub(/[^\d]/, '')

        @logger.debug "Checking: |#{address}|#{rooms}|#{year}| -- #{price} $"
        if ! @active_flats.include?(code)
          @active_flats << code
          update_price(code, area, address, price, rooms, year)
        else
          @logger.debug "Flat had been already parsed"
        end
      end
      # @logger.info "Updated #{@active_flats.size}/#{flats.size}"
    end
    mark_sold
  end
end

connection = JSONConnector.new('1.json')

ts = TSCrawler.new(connection)
ts.parse_flats
messages = ts.get_messages
message = ""
messages.each_key do |m_k|
  message += "*#{m_k}*\n"
  i = 0
  messages[m_k].each do |mes|
    message += "#{ mes }\n"
    i += 1
    if message.size > 4000
      send_message message
      message = ""
    end
  end
end
send_message message


connection.close
