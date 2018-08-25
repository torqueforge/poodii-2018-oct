gem 'minitest', '~> 5.11'
require 'minitest/autorun'
require 'minitest/pride'

require_relative '../lib/bowling'

class BowlingTest < Minitest::Test
  def test_gutter_game
    rolls = [0] * 20
    assert_equal 0, Bowling.new(rolls).score
  end
end
