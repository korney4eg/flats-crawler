require 'json'
require 'date'

# DAO class for flats
class JSONConnector
  def initialize( filename )
    @filename = filename
    @current_date = Time.now.strftime("%Y-%m-%d")
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

    add_flat_hist(code, price, @current_date)
  end

  def add_flat_hist(code, price, date = @current_date )
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
  end

  def get_all_flats
    @data['flats']
  end

  def update_flat(code, price)
    @data['flats'][code]['price'] = price
    add_flat_hist(code,price, @current_date)
  end

  def update_area(code, area)
    @data['flats'][code]['area'] = area
  end
  
  def update_status(code, status)
    @data['flats'][code]['status'] = status
  end

  def mark_sold(code)
    @data['flats'][code]['status'] = 'sold'
    if !@data['flats'][code]['sold_date']
      @data['flats'][code]['sold_date'] = @current_date
      return true
    else
      return false
    end
  end

  def mark_unsold(code)
    @data['flats'][code].delete('sold_date')
    @data['flats'][code].delete('status')
  end

  def fix_history_date_format
    @data['flats'].each_pair do |code,flat|
      temp_flat_hist = {}
      flat['history'].each_key do |flat_date|
        temp_flat_hist[Date::strptime(flat_date, "%Y-%m-%d")] = flat['history'][flat_date]
        puts "converted #{flat_date} ---> #{Date::strptime(flat_date, "%Y-%m-%d")}"
      end
      flat['history'] = temp_flat_hist
      if @data['flats'][code]['sold_date']
        @data['flats'][code]['sold_date'] = Date::strptime(@data['flats'][code]['sold_date'], "%Y-%m-%d")
      end
    end
  end

  def close
    file = File.new(@filename, 'w' )
    file.write(JSON.pretty_generate(@data))
    file.close
  end
end
