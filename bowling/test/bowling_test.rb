gem 'minitest', '~> 5.11'
require 'minitest/autorun'
require 'minitest/pride'

require_relative '../lib/bowling'

class BowlingTest < Minitest::Test
  def test_gutter_game
    rolls = [0] * 20
    assert_equal 0, Bowling.new(rolls).score
  end

  def test_all_ones
    rolls = [1] * 20
    assert_equal 20, Bowling.new(rolls).score
  end

  def test_one_spare
    rolls = [5, 5, 3] + [0] * 17
    assert_equal 16, Bowling.new(rolls).score
  end

  def test_one_strike
    rolls = [10, 3, 4] + [0] * 18
    assert_equal 24, Bowling.new(rolls).score
  end

  def test_perfect_game
    rolls = [10] * 12
    assert_equal 300, Bowling.new(rolls).score
  end

  def test_final_spare
    rolls = [1] * 18 + [4,6,4]
    assert_equal 32, Bowling.new(rolls).score
  end

  def test_scoring_partial_game_with_complete_frames
    rolls = [1] * 6
    assert_equal 6, Bowling.new(rolls).score
  end

  def test_scoring_partial_game_with_incomplete_final_frame
    rolls = [1] * 5
    assert_equal 4, Bowling.new(rolls).score
  end

  def test_scoring_partial_game_with_unfulfilled_strike
    rolls = [10] * 10
    assert_equal 240, Bowling.new(rolls).score
  end

  def test_scoring_partial_game_with_unfulfilled_spare
    rolls = [5,5,6,4]
    assert_equal 16, Bowling.new(rolls).score
  end
end
