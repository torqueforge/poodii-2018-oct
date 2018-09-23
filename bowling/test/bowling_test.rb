require_relative '../../test_helper'
require_relative '../lib/bowling'

class FramesTest < Minitest::Test
  def test_gutter_game
    rolls = [0] * 20
    assert_equal 0, Frames.for(rolls: rolls).score
  end

  def test_all_ones
    rolls = [1] * 20
    assert_equal 20, Frames.for(rolls: rolls).score
  end

  def test_one_spare
    rolls = [5, 5, 3] + [0] * 17
    assert_equal 16, Frames.for(rolls: rolls).score
  end

  def test_one_strike
    rolls = [10, 3, 4] + [0] * 18
    assert_equal 24, Frames.for(rolls: rolls).score
  end

  def test_perfect_game
    rolls = [10] * 12
    assert_equal 300, Frames.for(rolls: rolls).score
  end

  def test_final_spare
    rolls = [1] * 18 + [4,6,4]
    assert_equal 32, Frames.for(rolls: rolls).score
  end

  def test_scoring_partial_game_with_complete_frames
    rolls = [1] * 6
    assert_equal 6, Frames.for(rolls: rolls).score
  end

  def test_scoring_partial_game_with_incomplete_final_frame
    rolls = [1] * 5
    assert_equal 4, Frames.for(rolls: rolls).score
  end

  def test_scoring_partial_game_with_unfulfilled_strike
    rolls = [10] * 10
    assert_equal 240, Frames.for(rolls: rolls).score
  end

  def test_scoring_partial_game_with_unfulfilled_spare
    rolls = [5,5,6,4]
    assert_equal 16, Frames.for(rolls: rolls).score
  end

  # This test starts the road to ruin.
  # Consider:
  #  Why do we have to explicitly test NOTAP scoring here?
  #  What will happen to the tests when we add other bowling variants?
  def test_scoring_partial_notap_game_with_unfulfilled_spare
    rolls = [9,9,9,3,6,2]
    assert_equal 77, Frames.for(rolls: rolls, config: Variant::CONFIGS[:NOTAP]).score
  end

  # See the fear above has already come true. Our design means we'll
  # end up with a 'Frames' test for all possible outcomes for each
  # game variant.
  def test_scoring_partial_duckpin_game_with_unfulfilled_spare
    rolls = [1,1,1,2,2,2,10,2,2,3]
    assert_equal 30, Frames.for(rolls: rolls, config: Variant::CONFIGS[:DUCKPIN]).score
  end

  # Add some more test duplication to prove that LOWBALL works, prior to refactoring the tests
  def test_scoring_lowball_game_a
    rolls = [0,0,0,0,0,0]
    assert_equal 120, Frames.for(rolls: rolls, config: Variant::CONFIGS[:LOWBALL]).score
  end

  def test_scoring_lowball_game_b
    rolls = [1,0,2]
    assert_equal 13, Frames.for(rolls: rolls, config: Variant::CONFIGS[:LOWBALL]).score
  end
end
