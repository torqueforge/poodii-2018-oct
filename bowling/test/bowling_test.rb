require_relative '../../test_helper'
require_relative '../lib/bowling'


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


class LowballRollParserTest < Minitest::Test
  def setup
    @parser = LowballRollParser.new
  end

  def test_strike_with_all_bonus_rolls
    rolls = [0,1,2]
    expected = [1, 3, [10, 1, 2]]

    assert_equal expected, @parser.parse(rolls: rolls)
  end

  def test_strike_with_some_bonus_rolls
    rolls = [0,1]
    expected = [1, 3, [10, 1]]

    assert_equal expected, @parser.parse(rolls: rolls)
  end

  def test_strike_without_bonus_rolls
    rolls = [0]
    expected = [1, 3, [10]]

    assert_equal expected, @parser.parse(rolls: rolls)
  end

  def test_spare_with_all_bonus_rolls
    rolls = [1,0,2]
    expected = [2, 3, [1, 9, 2]]

    assert_equal expected, @parser.parse(rolls: rolls)
  end

  def test_spare_without_bonus_rolls
    rolls = [1,0]
    expected = [2, 3, [1,9]]

    assert_equal expected, @parser.parse(rolls: rolls)
  end

  def test_open_frame
    rolls = [1,2]
    expected = [2, 2, [1,2]]

    assert_equal expected, @parser.parse(rolls: rolls)
  end
end


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
end


######################################
# FrameAPI Test:
#   To be included within the unit test of
#   any object who wants to play the
#   'frame' role.
#######################################
module FrameAPITest
  def test_initialization_takes_correct_keyword_args
    @api_test_target.new(normal_rolls: nil, bonus_rolls: nil, status: nil)
  end
end

class FrameTest < Minitest::Test
  include FrameAPITest

  def setup
    @api_test_target = Frame
  end
end


######################################
# FrameStatusAPI Test:
#   To be included within the unit test of
#   any object who wants to play the
#   'frame status' role.
#######################################
module FrameStatusAPITest
  def test_implements_api
    f = @api_test_target.new
    [:score, :running_score, :normal_rolls_complete?, :bonus_rolls_complete?].each {|meth|
      assert_respond_to f, meth
    }
  end
end


######################################
# Dynamically generate FrameStatus API tests for
# players of the Frame Status role
######################################
[ FrameStatus::Complete,
  FrameStatus::MissingNormalRolls,
  FrameStatus::MissingBonusRolls].each {|status_class|

  Class.new(Minitest::Test) do
    include FrameStatusAPITest

    define_method :setup do
      @api_test_target = status_class
    end
  end
}


class DetailedScoresheetTest < Minitest::Test
  def setup
    @io = StringIO.new
  end

  def test_scoresheet_for_incomplete_game
    rolls  = (([10] * 3) + [1,2] + [3,3] + [4,0])
    frames = Frames.for(rolls: rolls)

    expected =
      "FRAME: |--1-----|--2-----|--3-----|--4-----|--5-----|--6-----|--7-----|--8-----|--9-----|-10-----|\n" +
      "PINS:  | 10.    | 10.    | 10.    |  1.  2 |  3.  3 |  4.  0 |   .    |   .    |   .    |   .    |\n" +
      "BONUS: | 10. 10 | 10.  1 |  1.  2 |   .    |   .    |   .    |   .    |   .    |   .    |   .    |\n" +
      "SCORE: | 30     | 21     | 13     |  3     |  6     |  4     |        |        |        |        |\n" +
      "TOTAL: | 30     | 51     | 64     | 67     | 73     | 77     |        |        |        |        |\n"

    DetailedScoresheet.new(frames: frames, io: @io).render
    assert_equal expected, @io.string
  end

  def test_scoresheet_for_complete_game
    rolls  = (([10] * 3) + [1,2] + [3,3] + [4,0] + [7,3] + ([3,4] * 3))
    frames = Frames.for(rolls: rolls)

    expected =
      "FRAME: |--1-----|--2-----|--3-----|--4-----|--5-----|--6-----|--7-----|--8-----|--9-----|-10-----|\n" +
      "PINS:  | 10.    | 10.    | 10.    |  1.  2 |  3.  3 |  4.  0 |  7.  3 |  3.  4 |  3.  4 |  3.  4 |\n" +
      "BONUS: | 10. 10 | 10.  1 |  1.  2 |   .    |   .    |   .    |  3.    |   .    |   .    |   .    |\n" +
      "SCORE: | 30     | 21     | 13     |  3     |  6     |  4     | 13     |  7     |  7     |  7     |\n" +
      "TOTAL: | 30     | 51     | 64     | 67     | 73     | 77     | 90     | 97     |104     |111     |\n"

    DetailedScoresheet.new(frames: frames, io: @io).render
    assert_equal expected, @io.string
  end

  def test_scoresheet_for_complete_game_of_three_roll_frames
    rolls  = (([10] * 3) + [1,2,3] + [3,3,0] + [4,0,0] + [7,3] + ([3,4,1] * 3))
    frames = Frames.for(rolls: rolls, config: Variant::CONFIGS[:DUCKPIN])

    expected =
    "FRAME: |--1---------|--2---------|--3---------|--4---------|--5---------|--6---------|--7---------|--8---------|--9---------|-10---------|\n" +
    "PINS:  | 10.   .    | 10.   .    | 10.   .    |  1.  2.  3 |  3.  3.  0 |  4.  0.  0 |  7.  3.    |  3.  4.  1 |  3.  4.  1 |  3.  4.  1 |\n" +
    "BONUS: | 10. 10.    | 10.  1.    |  1.  2.    |   .   .    |   .   .    |   .   .    |  3.   .    |   .   .    |   .   .    |   .   .    |\n" +
    "SCORE: | 30         | 21         | 13         |  6         |  6         |  4         | 13         |  8         |  8         |  8         |\n" +
    "TOTAL: | 30         | 51         | 64         | 70         | 76         | 80         | 93         |101         |109         |117         |\n"

    DetailedScoresheet.new(frames: frames, io: @io).render
    assert_equal expected, @io.string
  end
end

class GameTest < Minitest::Test
  def setup
    @input  = StringIO.new("\n\n\n\n\n")
    @output = StringIO.new
    @scoresheet_output = StringIO.new

    @player_name_prompt = "\nWho's playing? (Larry, Curly, Moe) >"
    @game_type_prompt   = "\nWhich game would %s like to play? (TENPIN) >"
    @expected_prompts   = (@player_name_prompt + ["Fee", "Fie", "Foe"].map{|name| @game_type_prompt % name}.join)

    @mock_answers       = "Fee, Fie, Foe\nTENPIN\nDUCKPIN\nNOTAP\n"

    @mixed_tenpin_game   = ([[6,2]] + ([[10]] * 2) + [[1,2]] + [[3,3]] + [[4,0]] + [[7,3]] + ([[3,4]] * 3))
    @mixed_duckkpin_game = (([[10]] * 3) + [[1,2,3]] + [[3,3,0]] + [[4,0,0]] + [[7,3]] + ([[3,4,1]] * 3))
    @strike_tenpin_game  = ([[10]] * 9) + [[10,10,10]]

    @three_alternating_player_game_pinfalls =
      @mixed_tenpin_game.zip(@mixed_duckkpin_game, @strike_tenpin_game).join("\n")

    @mock_answers_with_pinfalls = @mock_answers + @three_alternating_player_game_pinfalls
  end

  def start_game
    @game = Game.new(input: @input, output: @output, scoresheet_output: @scoresheet_output)
  end

  def starts_with?(str, io)
    io.string[0...str.size] == str
  end

  def ends_with?(str, io)
    io.string[(str.size * -1)..-1] == str
  end

  def assert_starts_with(expected, output)
    assert starts_with?(expected, output), "Expected ->\n  #{output.string[0..(expected.size+20)]}\n---------\nTo start with ->\n  #{expected}"
  end

  def assert_ends_with(expected, output)
    assert ends_with?(expected, output),  "Expected ->\n  #{output.string[(expected.size * -1)..-1]}\n---------\nTo start with ->\n  #{expected}"
  end

  def test_prompts_for_player_names
    expected = @player_name_prompt
    start_game
    assert starts_with?(expected, @output), "Expected #{@output}\nto start with #{expected}"
  end

  def test_defaults_to_stooges_players
    expected = ["Larry", "Curly", "Moe"]
    start_game
    assert_equal expected, @game.get_player_names
  end

  def test_accepts_user_specified_players
    @input.string = @mock_answers + "Fee, Fie, Foe\n"
    expected = ["Fee", "Fie", "Foe"]
    start_game
    assert_equal expected, @game.get_player_names
  end

  def test_prompts_players_for_game_variant
    @input.string = @mock_answers
    expected = @expected_prompts
    start_game
    assert_equal expected, @output.string
  end

  def test_defaults_to_tenpin_game_variant
    start_game
    assert_equal "TENPIN", @game.get_player_game_type("fake name to test type prompt")
  end

  def test_accepts_user_specified_game_variant
    @input.string = @mock_answers + "DUCKPIN\n"
    start_game
    assert_equal "DUCKPIN", @game.get_player_game_type("fake name to test type prompt")
  end

  def test_prompts_players_for_rolls
    @input.string = @mock_answers_with_pinfalls
    expected = @expected_prompts + "\n\nFee now starting frame 1"
    start_game
    @game.play
    assert_starts_with(expected, @output)
  end

  def test_prompts_for_rolls_until_turn_is_complete
    @input.string = @mock_answers_with_pinfalls
    expected = @expected_prompts + "\n\nFee now starting frame 1\n Roll? >\n Roll? >\n"
    start_game
    @game.play
    assert_starts_with(expected, @output)
  end

  def test_prints_scoresheet_after_turn
    @input.string = @mock_answers_with_pinfalls
    expected = "FRAME: |--1-----|-"
    start_game
    @game.play
    assert_starts_with(expected, @scoresheet_output)
  end

  def test_prints_game_summary
    @input.string = @mock_answers_with_pinfalls
    expected = "Game over, thanks for playing!\nFinal Scores:\n  Fee 89\n  Fie 117\n  Foe 300\n"
    start_game
    @game.play
    assert_ends_with(expected, @output)
  end
end
