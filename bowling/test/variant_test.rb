require_relative '../../test_helper'
require_relative '../bowling'

class TestParserWhichAlwaysReturnsTwoRollsOfOnePin
  def parse(rolls:, frame_configs:)
    [2,2,rolls.take(2)]
  end
end

class VariantTest < Minitest::Test
  def setup
    @config = {
      :parser     => "TestParserWhichAlwaysReturnsTwoRollsOfOnePin",
      :num_frames => 3,
    }

    @input_rolls = [1] * 5
  end

  def test_first_frame
    f = Variant.new(config: @config).framify(@input_rolls).first
    assert_equal 2, f.score
  end

  def test_second_frame
    f = Variant.new(config: @config).framify(@input_rolls)[1]
    assert_equal 2, f.score
  end

  def test_last_frame
    f = Variant.new(config: @config).framify(@input_rolls).last
    assert_nil f.score
  end
end