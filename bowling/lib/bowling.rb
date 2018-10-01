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