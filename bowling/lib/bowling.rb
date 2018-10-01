class Frames
  def self.for(rolls:, config: Variant::CONFIGS[:TENPIN])
    new(Variant.new(config: config).framify(rolls))
  end

  attr_reader :list
  def initialize(list)
    @list  = list
  end

  def score
    list.reduce(0) {|sum, frame| sum += frame.score}
  end
end


class Frame
  attr_reader :rolls
  def initialize(rolls:)
    @rolls = rolls
  end

  def score
    rolls.sum
  end
end


require 'ostruct'

class Variant
  CONFIGS = {
    :TENPIN => {
      :parser => "StandardRollParser",
      :scoring_rules => [
        {num_triggering_rolls: 1, triggering_value: 10, num_rolls_to_score: 3},
        {num_triggering_rolls: 2, triggering_value: 10, num_rolls_to_score: 3},
        {num_triggering_rolls: 2, triggering_value:  0, num_rolls_to_score: 2} ]
      },
    :NOTAP => {
      :parser => "StandardRollParser",
      :scoring_rules => [
        {num_triggering_rolls: 1, triggering_value: 9, num_rolls_to_score: 3},
        {num_triggering_rolls: 2, triggering_value: 9, num_rolls_to_score: 3},
        {num_triggering_rolls: 2, triggering_value: 0, num_rolls_to_score: 2} ]
      },
    :DUCKPIN => {
      :parser => "StandardRollParser",
      :scoring_rules => [
        {num_triggering_rolls: 1, triggering_value: 10, num_rolls_to_score: 3},
        {num_triggering_rolls: 2, triggering_value: 10, num_rolls_to_score: 3},
        {num_triggering_rolls: 3, triggering_value:  0, num_rolls_to_score: 3} ]
      },
    :LOWBALL => {
      :parser => "Don't have one yet",
      :scoring_rules => [ # The current structure won't work for LOWBALL
         ]
      }
    }

  attr_reader :config
  def initialize(config:)
    @config = OpenStruct.new(config)
  end

  def framify(rolls)
    frame_list    = []
    running_score = 0
    current_frame = 0
    max_frames    = 10
    remaining_rolls = rolls

    while current_frame < max_frames
      current_frame += 1

      # rule is used to determine
      #   how many rolls to score,
      #   how many rolls to drop, and
      #   the number of rolls that go into a frame,
      # but we don't know how to define generic scoring_rules for LOWBALL.
      num_triggering_rolls, num_rolls_to_score, roll_scores = parse(remaining_rolls)

      scoring_rolls =
        if remaining_rolls.size >=  num_rolls_to_score
          roll_scores
        else
          [0]
        end

      remaining_rolls = remaining_rolls.drop(num_triggering_rolls)
      frame_list << Frame.new(rolls: scoring_rolls)
    end

    frame_list
  end

    def parse(rolls)
      parser = Object.const_get(config.parser).new
      parser.parse(rolls: rolls, frame_configs: config.scoring_rules)
    end
end



# Extract the roll parsing responsibility.

# The #parse method below takes rolls and a list of frame_config hashes,
# and returns an array containing
#   number of triggering rolls
#   number of rolls to score
#   an array containing the score for every roll that contributes to this frame.
#
# Rules#framify could collaborate with this parser to get this information,
# rather than hard_coding its own logic to this.
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