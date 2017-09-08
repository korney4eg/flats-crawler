require "minitest/autorun"
require "./lib/connector-json.rb"

class TestConnector < Minitest::Test
  def setup
    @connector = JSONConnector.new('123.json')
    @connector.add_flat(1,10,'Kuprevicha 1/3',1000000,3,2016)
    @connector.add_flat(2,11,'Skaryny 3',100,3,2019)
    @connector.add_flat_hist(1, 1111, '2016-08-01')
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

  def test_that_we_have_two_dates
    assert_equal 2, @connector.get_dates.size
  end

  def test_that_we_have_two_flats
    assert_equal [1, 2 ], @connector.get_all_flats.keys
  end
end

