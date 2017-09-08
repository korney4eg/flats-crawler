require 'mongo'

# DAO class for flats
class DBConnector
  def initialize(host, db, user, password)
    @host = host
    @db = db
    @user = user
    @password = password
    @connection = Mysql2::Client.new(host: @host, database: @db,
      username: @user, password: @password)
  end

  def code_found(code)
    res = @connection.query("SELECT price from global where code=#{code};")
    res.size == 1
  end

  def add_flat(code, area, address, price, rooms, year)
    @connection.query('INSERT INTO global (code, area, address, price, rooms, year,status) VALUES '\
                "(#{code},#{area},\'#{address}\',#{price},\"#{rooms}\",#{year},\"new\");")
  end

  def add_flat_hist(code, price)
    time = Time.now
    @connection.query('INSERT INTO price_history (code, price, date)VALUES'\
      "(#{code},#{price},\"#{time.year}-#{time.month}-#{time.day}\");")
  end

  def get_last_price(code)
    price = @connection.query('SELECT price from price_history'\
                 " where code=#{code} ORDER BY date DESC LIMIT 1;")
    if price.size > 0
      price.first['price'].to_i
    else
      warn 'History of flat is broken ...'
      0
    end
  end
  
  def get_history
    flats = {}
    dates = get_dates
    dates.each do |date|
      flats[date] = []
      @connection.query("select code,price from price_history where date = '#{date}';").each do |flat|
        flats[date] += [ {flat['code'] => flat['price']} ]
#        puts "code = #{flat['code']}, price = #{flat['price']}"
      end
    end
    flats
  end

  def get_dates
    dates = []
    results = @connection.query('select distinct date from price_history;')
    results.each do |result|
      dates += [result['date']]
    end
    dates
  end

  def get_all_flats
    all_flats = []
    result = @connection.query("SELECT code FROM global where status != 'sold';")
    all_flats = result.map { |res| res['code']}
  end

  def update_flat(code, price, status)
    @connection.query("UPDATE global SET price=#{price}, status=\"#{status}\" WHERE code = #{code};")
  end

  def update_status(code, status)
    @connection.query("UPDATE global SET status=\"#{status}\" WHERE code = #{code};")
  end

  def update_area(code, area)
    @connection.query("UPDATE global SET area=#{area} WHERE code = #{code};")
  end
  
  def close
    @connection.close
  end
end
