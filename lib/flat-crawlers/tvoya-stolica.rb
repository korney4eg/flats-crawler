require './lib/flat-crawlers/base.rb'

# tvoya stalica crawler
class TSCrawler < FlatCrawler
  def read_configuration
    @rooms = [1,2,3]
    @price = [20_000, 100_000]
    @step = 10_000
    # Areas should be a list of areas,
    # here is the full list:
    # "avtozavod",  "akademiya-nauk",  "angarskaya",
    # "aerodromnaya-mogilevskaya-voronyanskogo", "brilevichi-druzhba",
    # "velozavod", "vesnyanka", "voennyy-gorodok-uruche",
    # "volgogradskaya-nezavisimosti-sevastopolskaya", "vostok", "grushevka",
    # "dzerzhinskogo-umanskaya-zheleznodorozhnaya", "dombrovka",  "z-gorka-pl-ya-kolasa",
    # "zavodskoy-rayon", "zapad", "zelenyy-lug",
    # "kalvariyskaya-kharkovskaya-pushkina", "kamennaya-gorka",
    # "kirova-marksa", "kozlova-zakharova", "komarovka",
    # "kommunisticheskaya-storozhevskaya-opernyy", "kuntsevshchina",
    # "kurasovshchina-", "lebyazhiy", "leninskiy-rayon", "loshitsa",
    # "makaenka-nezavisimosti-filimonova", "malinovka", "malyy-trostenets",
    # "masyukovshchina", "mayakovskogo", "mendeleeva-stoletova",
    # "mikhalovo", "moskovskiy-rayon", "odoevskogo-pushkina-pritytskogo",
    # "oktyabrskiy-rayon", "partizanskiy-rayon", "pervomayskiy-rayon",
    # "prigorod", "pushkina-glebki-olshevskogo-pritytskogo",
    # "r-lyuksemburg-k-libknekhta-rozochka",
    # "romanovskaya-sloboda-gorodskoy-val-myasnikova", "sedykh-tikotskogo",
    # "serebryanka", "serogo-asanalieva", "sovetskiy-rayon", "sokol",
    # "stepyanka", "surganova-bedy-bogdanovicha", "sukharevo",
    # "timiryazeva-pobediteley-masherova", "traktornyy-zavod",
    # "univermag-belarus", "uruche", "frunzenskiy-rayon",
    # "tsentralnyy-rayon", "tsna", "chervyakova-shevchenko-kropotkina",
    # "chizhovka", "shabany", "yugo-zapad"
     
    @areas = %w(
    akademiya-nauk
    aerodromnaya-mogilevskaya-voronyanskogo
    brilevichi-druzhba
    volgogradskaya-nezavisimosti-sevastopolskaya
    vostok
    grushevka
    dzerzhinskogo-umanskaya-zheleznodorozhnaya
    zelenyy-lug
    kalvariyskaya-kharkovskaya-pushkina
    lebyazhiy
    makaenka-nezavisimosti-filimonova
    malinovka
    masyukovshchina
    mayakovskogo
    mendeleeva-stoletova
    pushkina-glebki-olshevskogo-pritytskogo
    sedykh-tikotskogo
    surganova-bedy-bogdanovicha
    sukharevo
    uruche
    tsna
    chervyakova-shevchenko-kropotkina
    yugo-zapad
    )
    @years = [0, 2_018]
    @keywords = ''
    @page_urls = []
    @active_flats = []
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
      area = url.gsub(/=.*$/,'').gsub(/^.*area\[/,'').gsub(']','').to_i
      page = Nokogiri::HTML(open(url))
      flats = page.search('[class="flist__maplist-item paginator-item js-maphover"]')
      @logger.info "Number of flats found: #{flats.size}"
      flats.each do |flat|
        address = flat.css('[class="flist__maplist-item-props-name"]').text.gsub(/^[^,]*, /, '').gsub(/ *$/,'').strip
        price = flat.css('[class="flist__maplist-item-props-price-usd"]').text.gsub(/[^\d]*/,'').to_i
        rooms = flat.css('[class="flist__maplist-item-props-name"]').text.gsub(/-.*$/,'').to_i
        year = flat.css('[class="flist__maplist-item-props-years"]').text.to_i
        code = flat.css('a')[0]['href'].gsub(/[^\d]/, '')

        @logger.debug "Checking: |#{address}|#{rooms}|#{year}| -- #{price} $"
        if ! @active_flats.include?(code)
          @active_flats << code
          update_price(code, area, address, price, rooms, year)
        else
          @logger.debug "Flat had been already parsed"
        end
      end
      # @logger.info "Updated #{@active_flats.size}/#{flats.size}"
    end
    mark_sold
  end
end
