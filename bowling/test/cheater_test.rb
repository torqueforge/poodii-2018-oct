require_relative '../../test_helper'
require_relative '../bowling'

class CheaterTest < Minitest::Test
  def setup
    @cheater = Cheater.for(name: "Cheaty", rolls: [])
  end

  def test_cheater_leaves_rolls_of_5_or_more_untouched
    ignorable_rolls = (5..10).to_a

    ignorable_rolls.each {|r|
      c = @cheater.new_roll(r)

      assert_equal r, c.rolls.last
    }
  end

  def test_cheater_improves_rolls_of_less_than_5
    cheatable_rolls  = (0..4).to_a
    substitute_score = 8

    cheatable_rolls.each {|r|
      c = @cheater.new_roll(r)

      assert_equal substitute_score, c.rolls.last
    }
  end
end