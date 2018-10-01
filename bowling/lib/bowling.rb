class Bowling
  attr_reader :rolls, :config
  def initialize(rolls, config=Rules::CONFIGS[:TENPIN])
    @rolls  = rolls
    @config = config
  end

  def score
    frame_list = Rules.new(config: config).framify(rolls)
    frame_list.reduce(0) {|sum, frame| sum += frame.score}
  end
end


# Bowling class's sole responsiblity is to return the score
# of a list of frame objects.
# Maybe Bowling is really a Frames, like below.
class Frames
  def self.for(rolls:, config: Rules::CONFIGS[:TENPIN])
    new(Rules.new(config: config).framify(rolls))
  end

  attr_reader :list
  def initialize(list)
    @list  = list
  end

  def score
    list.reduce(0) {|sum, frame| sum += frame.score}
  end
end


require 'ostruct'

class Rules
  CONFIGS = {
    :TENPIN => {
      :scoring_rules => [
        {num_triggering_rolls: 1, triggering_value: 10, num_rolls_to_score: 3},
        {num_triggering_rolls: 2, triggering_value: 10, num_rolls_to_score: 3},
        {num_triggering_rolls: 2, triggering_value:  0, num_rolls_to_score: 2} ]
      },
    :NOTAP => {
      :scoring_rules => [
        {num_triggering_rolls: 1, triggering_value: 9, num_rolls_to_score: 3},
        {num_triggering_rolls: 2, triggering_value: 9, num_rolls_to_score: 3},
        {num_triggering_rolls: 2, triggering_value: 0, num_rolls_to_score: 2} ]
      },
    :DUCKPIN => {
      :scoring_rules => [
        {num_triggering_rolls: 1, triggering_value: 10, num_rolls_to_score: 3},
        {num_triggering_rolls: 2, triggering_value: 10, num_rolls_to_score: 3},
        {num_triggering_rolls: 3, triggering_value:  0, num_rolls_to_score: 3} ]
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
      rule = scoring_rule(remaining_rolls)

      scoring_rolls =
        if remaining_rolls.size >=  rule[:num_rolls_to_score]
          remaining_rolls.take(rule[:num_rolls_to_score])
        else
          [0]
        end
      remaining_rolls = remaining_rolls.drop(rule[:num_triggering_rolls])
      frame_list << Frame.new(rolls: scoring_rolls)
    end

    frame_list
  end

  def scoring_rule(rolls)
    config.scoring_rules.find {|rule|
      (rolls.take(rule[:num_triggering_rolls]).sum) >= rule[:triggering_value]
    }
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
