require 'mysql2'

class DBConnector
  def initialize(host, db, user, password)
    @host = host
    @db = db
    @user = user
    @password = password
    @connection = Mysql2::Client.new(host: @host, database: @db, username: @user,
       password: @password)
  end

  def code_found(code)
    res = @connection.query("SELECT price from global where code=#{code};")
    res.size == 1
  end

  def insert_flat(code, address, price, rooms, year)
    @connection.query('INSERT INTO global VALUES '\
                "(#{code},\'#{address}\',#{price},\"#{rooms}\",#{year});")
  end

  def instert_flat_hist(code, price)
    time = Time.now
    @connection.query('INSERT INTO price_history VALUES'\
      "(#{code},#{price},\"#{time.year}-#{time.month}-#{time.day}\");")
  end

  def get_last_price(code)
    @connection.query('SELECT code,price from price_history'\
                 " where code=#{code} ORDER BY date DESC;").first['price'].to_i
  end

  def update_flat(code, price)
    @connection.query("UPDATE global SET price=#{price} WHERE code = #{code});")
  end
end 
