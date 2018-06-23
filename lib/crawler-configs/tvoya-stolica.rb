require './lib/crawler-configs/base.rb'

class TSConfig < ParserConfigurator
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
    aerodromnaya-mogilevskaya-voronyanskogo
    akademiya-nauk
    brilevichi-druzhba
    chervyakova-shevchenko-kropotkina
    dzerzhinskogo-umanskaya-zheleznodorozhnaya
    frunzenskiy-rayon
    grushevka
    kalvariyskaya-kharkovskaya-pushkina
    lebyazhiy
    makaenka-nezavisimosti-filimonova
    malinovka
    masyukovshchina
    mayakovskogo
    mendeleeva-stoletova
    moskovskiy-rayon
    odoevskogo-pushkina-pritytskogo
    pervomayskiy-rayon
    pushkina-glebki-olshevskogo-pritytskogo
    r-lyuksemburg-k-libknekhta-rozochka
    romanovskaya-sloboda-gorodskoy-val-myasnikova
    sedykh-tikotskogo
    sovetskiy-rayon
    sukharevo
    surganova-bedy-bogdanovicha
    timiryazeva-pobediteley-masherova
    tsentralnyy-rayon
    tsna
    uruche
    voennyy-gorodok-uruche
    volgogradskaya-nezavisimosti-sevastopolskaya
    vostok
    yugo-zapad
    z-gorka-pl-ya-kolasa
    zelenyy-lug
    )
    @years = [0, 2_018]
    @keywords = ''
    @page_urls = []
    @active_flats = []
  end
end
