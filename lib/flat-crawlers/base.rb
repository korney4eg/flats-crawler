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
      @messages['New flats:'] << "[ #{address} ](https://www.t-s.by/buy/flats/#{code}/) ,cost #{price}\$ #{rooms} rooms, #{year}"
      @connection.add_flat(code, area, address, price, rooms, year)
    elsif price != last_price
      @logger.info "Updated flat:#{code} cost from #{last_price} -> #{price}$"
      @messages['Updated flats:'] << "[ #{address} ](https://www.t-s.by/buy/flats/#{code}/) cost from #{last_price} -> #{price}$"
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
         @messages['Sold flats:'] << "#{flat['code']} sold with price #{flat[ 'price' ]}$"
       end
    end
  end
end
