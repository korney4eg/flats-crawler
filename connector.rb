require 'mysql2'

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

  def add_flat(code, address, price, rooms, year)
    @connection.query('INSERT INTO global (code, address, price, rooms, year,status) VALUES '\
                "(#{code},\'#{address}\',#{price},\"#{rooms}\",#{year},\"new\");")
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

  def update_flat(code, price, status)
    @connection.query("UPDATE global SET price=#{price}, status=\"#{status}\" WHERE code = #{code};")
  end

  def close
    @connection.close
  end
end
