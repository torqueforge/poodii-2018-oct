require_relative '../../test_helper'
require_relative '../bowling'

class PlayerTest < Minitest::Test
  def setup
    name       = "Testy"
    orig_rolls = [1,1]
    new_roll   = 6

    @orig_player = Player.for(name: name, rolls: orig_rolls)
    @new_player  = @orig_player.new_roll(new_roll)
  end

  def test_player_accumulates_rolls
    assert_equal [1,1,6], @new_player.rolls
  end

  # def test_mutating_rolls_creates_new_player
  #   refute_equal @new_player.object_id, @orig_player.object_id
  # end

  def test_mutating_rolls_returns_existing_player
    assert_equal @new_player.object_id, @orig_player.object_id
  end
end