require 'nokogiri'
# Crawler class
class FlatCrawler
  def initialize(connection)
    @connection = connection
    configre_logging
    @logger.info "==================================================\n\n\n\n\n"
    @messages = { 'New flats:' => [], 'Updated flats:' => [], 'Sold flats:' => [] }
    
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

  def generate_urls(areas, price, step)
  end

  def get_messages
    return @messages
  end


  def update_flat(code, area, address, price, rooms, year)
    code_found = @connection.found_code?(code)
    last_price = @connection.get_last_price(code)
    if !code_found
      @logger.info "New flat:#{address} on area #{area} cost #{price}$ #{rooms} rooms, #{year}"
      @messages['New flats:'] << "[ #{address} ](https://www.t-s.by/buy/flats/#{code}/) ,cost #{price}\$ #{rooms} rooms, #{year}"
      @connection.add_flat(code, area, address, price, rooms, year)
    elsif price != last_price
      if price < last_price
        change_symbol = '↘'
      else
        change_symbol = '↗'
      end
      updates = @connection.get_history(code).keys.size
      @logger.info "Updated flat:#{code},#{updates} updates, #{last_price} #{change_symbol} #{price}$"
      @messages['Updated flats:'] << "[ #{address} ](https://www.t-s.by/buy/flats/#{code}/)| #{rooms} rooms | #{updates} upd| #{last_price} #{change_symbol} #{price}$"
      @connection.add_flat_hist(code, price)
      @connection.update_flat(code, price)
    else
      @logger.debug'nothing to do'
    end
    @connection.mark_unsold(code)
    @connection.update_area(code, area)
  end
  
  def mark_sold(active_flats)
    flats_codes_to_mark_sold = @connection.get_all_flats.keys.sort - active_flats.sort
    @logger.info "number of active flats is #{active_flats.size} flats"
    # @logger.info "Will mark as sold #{flats_to_mark_sold.size} flats"
    flats_codes_to_mark_sold.each do |sold_code|
      if @connection.mark_sold(sold_code)
        updates = @connection.get_history(sold_code).keys.size
        @logger.info "#{sold_code} to mark as sold| #{updates} upd"
        @messages['Sold flats:'] << "[#{sold_code}](https://www.t-s.by/buy/flats/#{sold_code}/) sold with price #{@connection.get_last_price(sold_code)}$| #{updates} upd"
      end
    end
  end
end
