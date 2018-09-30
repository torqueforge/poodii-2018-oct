require_relative '../../test_helper'
require_relative '../bowling'

#######################################
# Simplified (but entirely valid!) scoresheet
#######################################
class FakeScoresheet
  extend ScoresheetRenderingObserver

  attr_reader :out
  def initialize(frames:, io: $stdout)
    @out = io
  end

  def render
    out.puts "The scoresheet rendered!"
  end
end

class FakeScoresheetTest  < Minitest::Test
  include ScoresheetAPITest

  def setup
    @api_test_target = FakeScoresheet
  end
end

#######################################
class GameTest < Minitest::Test
  def setup
    @input  = StringIO.new("\n\n\n\n\n")
    @output = StringIO.new
    @scoresheet_output = StringIO.new
    @scoresheet_maker  = FakeScoresheet

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
    @game.add_observer(@scoresheet_maker)
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
    expected = "The scoresheet rendered!"
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
