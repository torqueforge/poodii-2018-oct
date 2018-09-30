require_relative '../../test_helper'
require_relative '../bowling'

class DetailedScoresheetTest < Minitest::Test
  include ScoresheetAPITest

  def setup
    @api_test_target = DetailedScoresheet
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
