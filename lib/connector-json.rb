require 'json'

# DAO class for flats
class JSONConnector
  def initialize( filename )
    @filename = filename
    begin
      file = File.read(@filename)
      @data = JSON.parse(file)
    rescue
      @data = {}
      @data['flats'] = {}
    end
    
  end

  def add_flat(code, area, address, price, rooms, year)
    @data['flats'][ code ] = {}
    @data['flats'][code]['area'] = area
    @data['flats'][code]['address'] =  address
    @data['flats'][code]['price'] = price
    @data['flats'][code]['rooms'] = rooms
    @data['flats'][code]['year'] = year
    @data['flats'][code]['status'] = ''
    @data['flats'][code]['history'] = {}

    time = Time.now
    add_flat_hist(code, price,"#{time.year}-#{time.month}-#{time.day}" )
  end

  def add_flat_hist(code, price, date ="#{Time.now.year}-#{Time.now.month}-#{Time.now.day}" )
    @data['flats'][code]['history'][ date ] = price
  end

  def found_code?(code)
    @data['flats'].has_key?(code)
  end

  def get_last_price(code)
    # puts "last price: #{ @data}"
    if found_code?(code)
      @data['flats'][code]['price']
    else
      0
    end
  end

  def get_history
    flats = {}
    dates = get_dates
    dates.each do |date|
      flats[date] = []
      # flats[date] << 
      @connection.query("select code,price from price_history where date =\
                        '#{date}';").each do |flat|
        flats[date] += [ {flat['code'] => flat['price']} ]
      end
    end
    flats
  end

  def get_dates
    dates = []
    @data['flats'].values.each do |flat|
      # puts flat['history']
      flat['history'].keys.each do |date|
        dates << date if not dates.include?(date)
      end
    end
    dates
  end

  def get_all_flats
    @data['flats']
  end

  def update_flat(code, price)
    @data['flats'][code]['price'] = price
    time = Time.now
    add_flat_hist(code,price,"#{time.year}-#{time.month}-#{time.day}")
  end

  def update_area(code, area)
  end
  
  def update_status(code, status)
    @data['flats'][code]['status'] = status
  end

  def close
    file = File.new(@filename, 'w' )
    file.write(JSON.dump(@data))
    file.close
  end
end
