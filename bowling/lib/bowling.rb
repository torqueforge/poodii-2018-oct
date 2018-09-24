class Frames
  include Enumerable

  def self.for(rolls:, config: Variant::CONFIGS[:TENPIN])
    variant = Variant.new(config: config)
    new(variant.framify(rolls), variant.config)
  end

  attr_reader :list, :max_rolls_per_turn
  def initialize(list, config)
    @list  = list
    @max_rolls_per_turn = config.max_rolls_per_turn
  end

  def score
    list.reduce(0) {|sum, frame| sum += frame.score.to_i}
  end

  def each
    list.each {|frame| yield frame}
  end
end

# Yes, tis hierachy has problems, but soon you'll be tasked to
# solve them.
class Frame
  attr_reader :normal_rolls, :bonus_rolls
  def initialize(normal_rolls: nil, bonus_rolls: nil)
    @normal_rolls = normal_rolls
    @bonus_rolls  = bonus_rolls
  end

  def score
    (normal_rolls + bonus_rolls).sum
  end
end

class PendingFrame < Frame
  def score
    nil
  end
end


class DetailedScoresheet
  attr_reader :frames, :out
  def initialize(frames:, io: $stdout)
    @frames = frames
    @out    = io
  end

  def pinfall_line
    ("PINS:  |" +
      frames.map {|frame|
        " " +
          ([frame.normal_rolls].flatten.compact.map {|item| sprintf("%2d", item) } + Array.new(frames.max_rolls_per_turn, '  ')).
            first(frames.max_rolls_per_turn).join(". ") +
        " "
      }.join("|") +
       "|")
  end

  def bonus_line
    ("BONUS: |" +
      frames.map {|frame|
        " " +
          ([frame.bonus_rolls].flatten.compact.map {|item| sprintf("%2d", item) } + Array.new(frames.max_rolls_per_turn, '  ')).
            first(frames.max_rolls_per_turn).join(". ") +
        " "
      }.join("|") +
       "|")
  end

  def score_line
    ("SCORE: |" +
      frames.map {|frame|
        " " +
          ([frame.score].flatten.compact.map {|item| sprintf("%2d", item) } + Array.new(frames.max_rolls_per_turn, '  ')).
            first(frames.max_rolls_per_turn).join(". ") +
        " "
      }.join("|") +
       "|")
  end
end


require 'ostruct'

class Variant
  CONFIGS = {
    :TENPIN => {
      :parser => "StandardRollParser",
      :max_rolls_per_turn => 2,
      :scoring_rules => [
        {num_triggering_rolls: 1, triggering_value: 10, num_rolls_to_score: 3},
        {num_triggering_rolls: 2, triggering_value: 10, num_rolls_to_score: 3},
        {num_triggering_rolls: 2, triggering_value:  0, num_rolls_to_score: 2} ]
      },
    :NOTAP => {
      :max_rolls_per_turn => 2,
      :parser => "StandardRollParser",
      :scoring_rules => [
        {num_triggering_rolls: 1, triggering_value: 9, num_rolls_to_score: 3},
        {num_triggering_rolls: 2, triggering_value: 9, num_rolls_to_score: 3},
        {num_triggering_rolls: 2, triggering_value: 0, num_rolls_to_score: 2} ]
      },
    :DUCKPIN => {
      :max_rolls_per_turn => 3,
      :parser => "StandardRollParser",
      :scoring_rules => [
        {num_triggering_rolls: 1, triggering_value: 10, num_rolls_to_score: 3},
        {num_triggering_rolls: 2, triggering_value: 10, num_rolls_to_score: 3},
        {num_triggering_rolls: 3, triggering_value:  0, num_rolls_to_score: 3} ]
      },
    :LOWBALL => {
      :max_rolls_per_turn => 2,
      :parser => "LowballRollParser",
      :scoring_rules => [ # The current structure won't work for LOWBALL
         ]
      }
    }

  attr_reader :config, :parser
  def initialize(config:)
    @config = OpenStruct.new(config)
    @parser = Object.const_get(self.config.parser).new
  end

  def framify(rolls)
    frame_list    = []
    current_frame = 0
    max_frames    = 10
    remaining_rolls = rolls

    while current_frame < max_frames
      current_frame += 1
      num_triggering_rolls, num_rolls_to_score, roll_scores = parse(remaining_rolls)

      # The problem with pending rolls showing up a 0 originates right here.
      # We need a kind of frame that returns nothing (nil) for rolls that haven't happened.
      frame_class =
        if remaining_rolls.size >=  num_rolls_to_score
          Frame
        else
          PendingFrame
        end

      normal = roll_scores.take(num_triggering_rolls)
      bonus  = roll_scores[num_triggering_rolls...num_rolls_to_score] || []

      remaining_rolls = remaining_rolls.drop(num_triggering_rolls)
      frame_list << frame_class.new(normal_rolls: normal, bonus_rolls: bonus)
    end

    frame_list
  end

  def parse(rolls)
    parser.parse(rolls: rolls, frame_configs: config.scoring_rules)
  end
end


########################## Roll Parsers #############################

#############################
# StandardRollParser uses rules specified in a configuration hash
# to parse frame information from a list of rolls.
#
# It returns the original pinfall as the score for each roll.
#############################
class StandardRollParser

  def parse(rolls:, frame_configs:)

    # Select the applicable frame config
    cfg =
      frame_configs.find {|frame_cfg|
        (rolls.take(frame_cfg[:num_triggering_rolls]).sum) >= frame_cfg[:triggering_value]
      }

      [ cfg[:num_triggering_rolls], cfg[:num_rolls_to_score], rolls.take(cfg[:num_rolls_to_score]) ]
  end
end

#############################
# LowBallParse contains redundant, duplicative, awkward logic
#  to parse frame information from a list of rolls.
#
# The rules are:
#   If 1st roll is 0,
#     roll_score is 10 and you get 2 bonus rolls.
#
#   If 2nd roll is 0,
#     roll_score for 2nd roll is 10-1st roll, and you get 1 bonus roll.
#
#   Open frame is two non-zero rolls.
#
# By definition, it returns an alternate score for some input pinfalls.
#############################
class LowballRollParser

  def parse(rolls:, frame_configs: nil)

    # strike
    if rolls[0] == 0
      num_triggering_rolls = 1
      num_rolls_to_score   = 3
      roll_scores = [10]

      roll_scores +=
        (if   rolls[1] == 0 && rolls[2] == 0
          [10, 10]

        elsif rolls[1] == 0 && rolls[2] != 0
          [10, rolls[2]]

        elsif rolls[1] != 0 && rolls[2] == 0
          [rolls[1], 10-rolls[1]]

        else
          [rolls[1], rolls[2]]
        end)

    # spare
    elsif
      if rolls[1] == 0
        num_triggering_rolls = 2
        num_rolls_to_score   = 3

        roll_scores = [rolls[0], (10-rolls[0])]

        roll_scores +=
          (if rolls[2] == 0
            [10]
          else
            [rolls[2]]
          end)
      end

    # open frame
    else
      num_triggering_rolls = 2
      num_rolls_to_score   = 2
      roll_scores = [rolls[0], rolls[1]]
    end

    [num_triggering_rolls, num_rolls_to_score, roll_scores.compact]
  end
end