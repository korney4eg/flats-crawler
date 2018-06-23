require "minitest/autorun"
require "./lib/connector-json.rb"
require "./lib/crawler-configs/tvoya-stolica-test.rb"
require './lib/flat-crawlers/tvoya-stolica.rb'
require 'logger'

class TestCrawler < Minitest::Test
  def setup
    @connector = JSONConnector.new('123.json')
    @connector.add_flat(1,10,'Kuprevicha 1/3',1000000,3,2016)
    @connector.add_flat(2,11,'Skaryny 3',100,3,2019)
    @connector.add_flat_hist(1, 1111, '2016-08-01')
    @parserConfig = TSTestConfig.new
    @parserConfig.read_configuration
    @ts = TSCrawler.new(@connector)

  end

  def test_that_flat_with_code_one_exists
    assert_equal true, @connector.found_code?(1)
  end

  def test_that_flat_with_code_two_exists
    assert_equal true, @connector.found_code?(2)
  end

  def test_last_price_of_first_flat
    assert_equal 1000000, @connector.get_last_price(1)
  end

  def test_that_we_have_two_flats
    assert_equal [1, 2], @connector.get_all_flats.keys
  end

  def test_that_crawler_rooms_configured_properly
    assert_equal [1], @parserConfig.rooms
  end

  def test_that_crawler_prices_configured_properly
    assert_equal [20_000, 100_000], @parserConfig.price
  end

  def test_that_pars_urls_generated_properly
    assert_equal ["https://www.t-s.by/buy/flats/filter/district-is-chervyakova-shevchenko-kropotkina/",
                  "https://www.t-s.by/buy/flats/filter/district-is-uruche/"],
                  @ts.generate_urls(@parserConfig.areas, @parserConfig.price, @parserConfig.step)
  end

  def test_after_adding_flat
    @ts.update_flat(3, 'kropotkina', 'Test address 2', 10000, 2, 2017)
    assert_equal [1, 2,3], @connector.get_all_flats.keys
  end

  def test_after_changing_flat
    @ts.update_flat(1, 'kropotkina', 'Test address 2', 100, 2, 2017)
    assert_equal 100, @connector.get_last_price(1)
  end

  def test_after_mark_flat_as_sold
    @ts.mark_sold([1,3])
    assert_equal 'sold', @connector.get_status(2)
  end
end
