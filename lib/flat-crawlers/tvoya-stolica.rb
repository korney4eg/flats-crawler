require './lib/flat-crawlers/base.rb'

# tvoya stalica crawler
class TSCrawler < FlatCrawler

  def generate_urls(areas, price, step)
    page_urls = []
    areas.each do |area|
      (price[0]..price[0]).step(step) do |pr|
        page_url = 'https://www.t-s.by/buy/flats/filter/'
        page_url += "district-is-#{area}/"
        # page_url += 'daybefore=1&'
        # page_url += "year[min]=#{years[0]}&year[max]=#{years[1]}&"
        # page_url += "price[min]=#{pr}&price[max]=#{pr + step}&keywords="
        page_urls += [page_url]
      end
    end
    return page_urls
  end

  def parse_flats(page_urls)
    active_flats = []
    page_urls.each do |url|
      @logger.info "Crawling on URL: #{url}"
      area = url.gsub(/^.*district-is-/,'').sub('/','')
      page = Nokogiri::HTML(open(url))
      flats = page.search('[class="flist__maplist-item paginator-item js-maphover"]')
      @logger.info "Number of flats found: #{flats.size}"
      flats.each do |flat|
        address = flat.css('[class="flist__maplist-item-props-name"]').text.gsub(/^[^,]*, /, '').gsub(/ *$/,'').strip
        price = flat.css('[class="flist__maplist-item-props-price-usd"]').text.gsub(/[^\d]*/,'').to_i
        rooms = flat.css('[class="flist__maplist-item-props-name"]').text.gsub(/-.*$/,'').to_i
        year = flat.css('[class="flist__maplist-item-props-years"]').text.to_i
        code = flat.css('a')[0]['href'].gsub(/^.*-/, '')

        @logger.debug "Checking: |#{address}|#{rooms}|#{year}| -- #{price} $"
        if ! active_flats.include?(code)
          active_flats << code
          update_flat(code, area, address, price, rooms, year)
          
        else
          @logger.debug "Flat had been already parsed"
        end
      end
      # @logger.info "Updated #{active_flats.size}/#{flats.size}"
    end
    return active_flats
  end
end
