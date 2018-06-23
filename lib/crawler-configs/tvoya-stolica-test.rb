require './lib/crawler-configs/base.rb'

class TSTestConfig < ParserConfigurator
  def read_configuration
    @rooms = [1]
    @price = [20_000, 100_000]
    @step = 10_000

    @areas = %w(
    chervyakova-shevchenko-kropotkina
    uruche
    )
    @years = [0, 2_018]
    @keywords = ''
    @active_flats = []


    @logger = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG
    @logger.formatter = proc do |severity, datetime, progname, msg|
      "#{datetime}|  #{severity}: #{msg}\n"
    end
  end
end
