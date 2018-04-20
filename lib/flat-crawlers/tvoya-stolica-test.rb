require './lib/flat-crawlers/base.rb'

# tvoya stalica crawler
class TSTestCrawler < FlatCrawler
  def read_configuration
    @rooms = [1]
    @price = [20_000, 100_000]
    @step = 10_000
     
    @areas = %w(
    chervyakova-shevchenko-kropotkina
    )
    @years = [0, 2_018]
    @keywords = ''
    @page_urls = []
    @active_flats = []
  end

  def configre_logging
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG
    @logger.formatter = proc do |severity, datetime, progname, msg|
      "#{datetime}|  #{severity}: #{msg}\n"
    end
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
      # area = url.gsub(/=.*$/,'').gsub(/^.*area\[/,'').gsub(']','').to_i
      page = Nokogiri::HTML(open(url))
      flats = page.search('[class="flist__maplist-item paginator-item js-maphover"]')
      @logger.info "Number of flats found: #{flats.size}"
      flats.each do |flat|
        address = flat.css('[class="flist__maplist-item-props-name"]').text.gsub(/^[^,]*, /, '').gsub(/ *$/,'').strip
        price = flat.css('[class="flist__maplist-item-props-price-usd"]').text.gsub(/[^\d]*/,'').to_i
        rooms = flat.css('[class="flist__maplist-item-props-name"]').text.gsub(/-.*$/,'').to_i
        year = flat.css('[class="flist__maplist-item-props-years"]').text.to_i
        code = flat.css('a')[0]['href'].gsub(/[^\d]/, '')
        @logger.info "Checking: code='#{code}'|address = '#{address}'|rooms='#{rooms}'|year = '#{year}'| -- price ='#{price}' $"
      end
      # @logger.info "Updated #{@active_flats.size}/#{flats.size}"
    end
  end
end
