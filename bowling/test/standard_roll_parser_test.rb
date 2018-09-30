require_relative '../../test_helper'
require_relative '../bowling'

class StandardRollParserTest < Minitest::Test
  def setup
    @parser = StandardRollParser.new
    @configs = [
      {num_triggering_rolls: 1, triggering_value: 11, num_rolls_to_score: 4},  # strike
      {num_triggering_rolls: 2, triggering_value: 11, num_rolls_to_score: 4},  # spare
      {num_triggering_rolls: 2, triggering_value:  8, num_rolls_to_score: 3},  # hug
      {num_triggering_rolls: 2, triggering_value:  0, num_rolls_to_score: 2} ] # open
  end

  def test_strike_with_all_bonus_rolls
    rolls = [11,12,13,14]
    expected = [1, 4, [11,12,13,14]]

    assert_equal expected, @parser.parse(rolls: rolls, frame_configs: @configs)
  end

  def test_strike_with_some_bonus_rolls
    rolls = [11,12]
    expected = [1, 4, [11,12]]

    assert_equal expected, @parser.parse(rolls: rolls, frame_configs: @configs)
  end

  def test_strike_without_bonus_rolls
    rolls = [11]
    expected = [1, 4, [11]]

    assert_equal expected, @parser.parse(rolls: rolls, frame_configs: @configs)
  end

  def test_spare_with_all_bonus_rolls
    rolls = [7,4,1,2]
    expected = [2, 4, [7,4,1,2]]

    assert_equal expected, @parser.parse(rolls: rolls, frame_configs: @configs)
  end

  def test_spare_with_some_bonus_rolls
    rolls = [7,4,1]
    expected = [2, 4, [7,4,1]]

    assert_equal expected, @parser.parse(rolls: rolls, frame_configs: @configs)
  end

  def test_strike_without_bonus_rolls
    rolls = [7,4]
    expected = [2, 4, [7,4]]

    assert_equal expected, @parser.parse(rolls: rolls, frame_configs: @configs)
  end

  def test_hug_with_all_bonus_rolls
    rolls = [4,4,1]
    expected = [2, 3, [4,4,1]]

    assert_equal expected, @parser.parse(rolls: rolls, frame_configs: @configs)
  end

  def test_hug_without_bonus_rolls
    rolls = [4,4]
    expected = [2, 3, [4,4]]

    assert_equal expected, @parser.parse(rolls: rolls, frame_configs: @configs)
  end

  def test_open_frame
    rolls = [1,2]
    expected = [2, 2, [1,2]]

    assert_equal expected, @parser.parse(rolls: rolls, frame_configs: @configs)
  end
end
