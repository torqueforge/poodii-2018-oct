require_relative '../../test_helper'
require_relative '../bowling'

class ClassicScoresheetAdaptorTest < Minitest::Test
  include ScoresheetAPITest

  def setup
    @api_test_target = ClassicScoresheetAdaptor
    @io = StringIO.new
  end

  def test_scoresheet_for_complete_game
    rolls  = (([10] * 3) + [1,2] + [3,3] + [4,0] + [7,3] + ([3,4] * 3))
    frames = Frames.for(rolls: rolls)

    expected =
      "\n+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+\n" +
      "|  F1   |  F2   |  F3   |  F4   |  F5   |  F6   |  F7   |  F8   |  F9   |    F10    |\n" +
      "+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+\n" +
      "|   | \e[32mX\e[0m |   | \e[32mX\e[0m |   | \e[32mX\e[0m | 1 | 2 | 3 | 3 | 4 | 0 | 7 | \e[38;5;214m/\e[0m | 3 | 4 | 3 | 4 | 3 | 4 |   |\n" +
      "|   ┕━━━┙   ┕━━━┙   ┕━━━┙   ┕━━━┙   ┕━━━┙   ┕━━━┙   ┕━━━┙   ┕━━━┙   ┕━━━┙   ┕━━━┻━━ |\n" +
      "|  \e[1m30\e[0m   |  \e[1m51\e[0m   |  \e[1m64\e[0m   |  \e[1m67\e[0m   |  \e[1m73\e[0m   |  \e[1m77\e[0m   |  \e[1m90\e[0m   |  \e[1m97\e[0m   |  \e[1m104\e[0m  |    \e[1m111\e[0m    |\n" +
      "+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+\n"

    ClassicScoresheetAdaptor.new(frames: frames, io: @io).render
    assert_equal expected, @io.string
  end
end

# rolls = [[7,3],[10],[1,8,2],[4,4,0],[5,0,0],[6,0,0],[7,0,0],[8,0,0],[9,0,0],[10,3,7]].flatten
# ClassicScoresheet.new(frames: Frames.for(rolls: rolls, config: Variant::CONFIGS[:DUCKPIN])).print

# rolls = [[7,3],[10],[1,8],[4,4],[5,0],[6,0],[7,0],[8,0],[9,0],[10,3,7]].flatten
# ClassicScoresheet.new(frames: Frames.for(rolls: rolls, config: Variant::CONFIGS[:TENPIN])).print

# rolls = [[7,3],[10],[1,2]].flatten
# ClassicScoresheet.new(frames: Frames.for(rolls: rolls, config: Variant::CONFIGS[:TENPIN])).print
