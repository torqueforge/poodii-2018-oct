class Bowling
  attr_reader :rolls, :config
  def initialize(rolls, config=Rules::CONFIGS[:TENPIN])
    @rolls  = rolls
    @config = config
  end

  def score
    running_score = 0
    current_frame = 0
    max_frames    = 10
    remaining_rolls = rolls

    while current_frame < max_frames
      current_frame += 1
      rule = Rules.new(config: config).scoring_rule(remaining_rolls)

      if (remaining_rolls.take(rule[:num_triggering_rolls]).sum) >= rule[:triggering_value]
        if remaining_rolls.size >=  rule[:num_rolls_to_score]
          running_score  += remaining_rolls.take(rule[:num_rolls_to_score]).sum
          remaining_rolls = remaining_rolls.drop(rule[:num_triggering_rolls])
        end
        next
      end
    end

    running_score
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
      }
    }

  attr_reader :config
  def initialize(config:)
    @config = OpenStruct.new(config)
  end

  def scoring_rule(rolls)
    config.scoring_rules.find {|rule|
      (rolls.take(rule[:num_triggering_rolls]).sum) >= rule[:triggering_value]
    }
  end
end
